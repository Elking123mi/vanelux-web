# Vanelux Security & Transparency

## Security Policy

### Reporting a Vulnerability

If you discover a security vulnerability within Vanelux, please send an email to security@vanelux.com. All security vulnerabilities will be promptly addressed.

Please do not report security vulnerabilities through public GitHub issues.

### Supported Versions

We release patches for security vulnerabilities. Currently supported:

- Latest production version (always)

### Security Measures

- **HTTPS Only**: All traffic is encrypted with TLS 1.3
- **Content Security Policy**: Strict CSP headers to prevent XSS attacks
- **HSTS**: HTTP Strict Transport Security enabled
- **PCI DSS Compliant**: Payment processing via Stripe (Level 1 PCI certified)
- **Data Encryption**: All sensitive data encrypted at rest and in transit
- **Rate Limiting**: Protection against brute-force attacks
- **Regular Audits**: Security audits and penetration testing

### Privacy

See our [Privacy Policy](https://www.vane-lux.com/privacy-policy.html) for details on how we handle your data.

### Authentication

- Google OAuth 2.0
- Facebook Login
- JWT tokens for session management
- Secure password hashing with bcrypt

### Third-Party Services

- **Stripe**: Payment processing (PCI DSS Level 1)
- **Supabase**: Database hosting with row-level security
- **Google Maps**: Location and routing services
- **Netlify**: CDN and hosting with DDoS protection

## Contact

For security inquiries: security@vanelux.com
For general inquiries: info@vanelux.com
Phone: +1 (917) 599-5522
