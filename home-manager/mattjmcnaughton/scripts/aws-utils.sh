#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# AWS Utilities Script
# A wrapper around common AWS CLI commands

log() {
    local level="$1"
    shift
    echo "$(date +"%Y-%m-%d %H:%M:%S") [$level] $*"
}

log_info()  { log "INFO" "$@"; }
log_warn()  { log "WARN" "$@"; }
log_error() { log "ERROR" "$@" >&2; }

show_help() {
    cat << EOF
AWS Utilities Script

USAGE:
    aws-utils COMMAND [OPTIONS]

COMMANDS:
    list-instances         List all EC2 instances with their status
    start-instance         Start an EC2 instance by name
    stop-instance          Stop an EC2 instance by name
    list-secrets           List all secrets in AWS Secrets Manager
    get-secret             Get the contents of a secret from AWS Secrets Manager
    upsert-secret          Create or update a secret in AWS Secrets Manager
    help                   Show this help message

OPTIONS:
    --region REGION        AWS region to use (defaults to AWS_REGION env var)
    --profile PROFILE      AWS profile to use
    --dry-run              Print the AWS CLI command instead of running it
    --name NAME            Name for instance or secret operations
    --secret-string STRING Content for secret creation/update
    --secret-file FILE     File containing content for secret creation/update
    --prefix PREFIX        Filter secrets by prefix (for list-secrets)

EXAMPLES:
    aws-utils list-instances
    aws-utils start-instance --name my-instance
    aws-utils stop-instance --name my-instance
    aws-utils list-secrets
    aws-utils list-secrets --prefix prod/
    aws-utils get-secret --name my-secret
    aws-utils upsert-secret --name my-secret --secret-string '{"key":"value"}'
    aws-utils upsert-secret --name my-secret --secret-file ./secret.json
EOF
}

run_command() {
    local cmd="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would execute: $cmd"
    else
        log_info "Executing: $cmd"
        eval "$cmd"
    fi
}

list_instances() {
    local cmd="aws ec2 describe-instances"

    if [[ -n "$REGION" ]]; then
        cmd="$cmd --region $REGION"
    fi

    if [[ -n "$PROFILE" ]]; then
        cmd="$cmd --profile $PROFILE"
    fi

    cmd="$cmd --query 'Reservations[*].Instances[*].[InstanceId, State.Name, Tags[?Key==\`Name\`].Value | [0]]' --output table"

    run_command "$cmd"
}

manage_instance() {
    local action="$1"

    if [[ -z "$NAME" ]]; then
        log_error "Instance name is required. Use --name option."
        exit 1
    fi

    local instance_id_cmd="aws ec2 describe-instances --filters \"Name=tag:Name,Values=$NAME\""

    if [[ -n "$REGION" ]]; then
        instance_id_cmd="$instance_id_cmd --region $REGION"
    fi

    if [[ -n "$PROFILE" ]]; then
        instance_id_cmd="$instance_id_cmd --profile $PROFILE"
    fi

    instance_id_cmd="$instance_id_cmd --query \"Reservations[*].Instances[*].InstanceId\" --output text"

    local cmd="aws ec2 $action-instances --instance-ids \$($instance_id_cmd)"

    if [[ -n "$REGION" ]]; then
        cmd="$cmd --region $REGION"
    fi

    if [[ -n "$PROFILE" ]]; then
        cmd="$cmd --profile $PROFILE"
    fi

    run_command "$cmd"
}

list_secrets() {
    local cmd="aws secretsmanager list-secrets"

    if [[ -n "$REGION" ]]; then
        cmd="$cmd --region $REGION"
    fi

    if [[ -n "$PROFILE" ]]; then
        cmd="$cmd --profile $PROFILE"
    fi

    if [[ -n "$PREFIX" ]]; then
        cmd="$cmd --filter Key=name,Values=$PREFIX"
    fi

    cmd="$cmd --query 'SecretList[*].[Name, LastChangedDate, Description]' --output table"

    run_command "$cmd"
}

get_secret() {
    if [[ -z "$NAME" ]]; then
        log_error "Secret name is required. Use --name option."
        exit 1
    fi

    local cmd="aws secretsmanager get-secret-value --secret-id $NAME"

    if [[ -n "$REGION" ]]; then
        cmd="$cmd --region $REGION"
    fi

    if [[ -n "$PROFILE" ]]; then
        cmd="$cmd --profile $PROFILE"
    fi

    cmd="$cmd --query SecretString --output text"

    run_command "$cmd"
}

upsert_secret() {
    if [[ -z "$NAME" ]]; then
        log_error "Secret name is required. Use --name option."
        exit 1
    fi

    if [[ -z "$SECRET_STRING" && -z "$SECRET_FILE" ]]; then
        log_error "Secret content is required. Use --secret-string or --secret-file option."
        exit 1
    fi

    # Check if secret exists
    local check_cmd="aws secretsmanager describe-secret --secret-id $NAME"

    if [[ -n "$REGION" ]]; then
        check_cmd="$check_cmd --region $REGION"
    fi

    if [[ -n "$PROFILE" ]]; then
        check_cmd="$check_cmd --profile $PROFILE"
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        if $check_cmd &>/dev/null; then
            SECRET_EXISTS="true"
        else
            SECRET_EXISTS="false"
        fi
    else
        log_info "DRY RUN: Would check if secret $NAME exists"
        SECRET_EXISTS="unknown"
    fi

    if [[ "$SECRET_EXISTS" == "true" ]]; then
        local cmd="aws secretsmanager put-secret-value --secret-id $NAME"
    else
        local cmd="aws secretsmanager create-secret --name $NAME"
    fi

    if [[ -n "$REGION" ]]; then
        cmd="$cmd --region $REGION"
    fi

    if [[ -n "$PROFILE" ]]; then
        cmd="$cmd --profile $PROFILE"
    fi

    if [[ -n "$SECRET_STRING" ]]; then
        cmd="$cmd --secret-string '$SECRET_STRING'"
    elif [[ -n "$SECRET_FILE" ]]; then
        cmd="$cmd --secret-string file://$SECRET_FILE"
    fi

    run_command "$cmd"
}

# Default values
COMMAND=""
REGION=""
PROFILE=""
DRY_RUN="false"
NAME=""
SECRET_STRING=""
SECRET_FILE=""
SECRET_EXISTS=""
PREFIX=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        list-instances|start-instance|stop-instance|list-secrets|get-secret|upsert-secret|help)
            COMMAND="$1"
            shift
            ;;
        --region)
            REGION="$2"
            shift 2
            ;;
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --name)
            NAME="$2"
            shift 2
            ;;
        --secret-string)
            SECRET_STRING="$2"
            shift 2
            ;;
        --secret-file)
            SECRET_FILE="$2"
            shift 2
            ;;
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Execute command
case "$COMMAND" in
    list-instances)
        list_instances
        ;;
    start-instance)
        manage_instance "start"
        ;;
    stop-instance)
        manage_instance "stop"
        ;;
    list-secrets)
        list_secrets
        ;;
    get-secret)
        get_secret
        ;;
    upsert-secret)
        upsert_secret
        ;;
    help|"")
        show_help
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
