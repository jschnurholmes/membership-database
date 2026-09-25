# Keep the SDK's per-request logging but redact email message content, which
# carries password reset tokens.
Aws.config.update(log_formatter: Aws::Log::Formatter.default(filter: [:content]))
