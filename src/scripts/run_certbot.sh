#!/bin/bash

# Source in util.sh so we can have our nice tools
. $(cd $(dirname $0); pwd)/util.sh

# We require an email to register the ssl certificate for
if [ -z "$CERTBOT_EMAIL" ]; then
    error "CERTBOT_EMAIL environment variable undefined; certbot will do nothing"
    exit 1
fi

set -x
# Loop over every domain we can find
for domain in $(parse_domains); do
    if is_renewal_required $domain; then
        # Renewal required for this doman.
        # Last one happened over a week ago (or never)
        if ! get_certificate $domain $CERTBOT_EMAIL; then
            error "Cerbot failed for $domain. Check the logs for details."
            exit 1
        fi
    else
        echo "Not run certbot for $domain; last renewal happened just recently."
    fi
done

# After trying to get all our certificates, auto enable any configs that we
# did indeed get certificates for
auto_enable_configs

# Finally, tell nginx to reload the configs
kill -HUP $NGINX_PID

set +x
