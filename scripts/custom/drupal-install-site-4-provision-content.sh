#!/usr/bin/env bash
##
# Provision content.
#
# shellcheck disable=SC2086

set -e
[ -n "${DREVOPS_DEBUG}" ] && set -x

# Path to the application.
APP="${APP:-/app}"

# ------------------------------------------------------------------------------

# Use local or global Drush, giving priority to a local drush.
drush="$(if [ -f "${APP}/vendor/bin/drush" ]; then echo "${APP}/vendor/bin/drush"; else command -v drush; fi)"

if [ -n "${CIVICTHEME_CONTENT_PROFILE}" ]; then
  echo "  > Provisioning content from \"${CIVICTHEME_CONTENT_PROFILE}\" content profile."
  $drush -y pm-enable civictheme_content
else
  echo "  > Provisioning content from theme defaults."
  $drush php:eval -v "require_once '/app/docroot/themes/contrib/civictheme/theme-settings.provision.inc'; civictheme_provision_cli();"
fi

if [ "${CIVICTHEME_GENERATED_CONTENT_CREATE_SKIP}" != "1" ]; then
  echo "  > Generate test content."
  GENERATED_CONTENT_CREATE=1 $drush -y pm-enable cs_generated_content

  if $drush pm-list --status=enabled | grep -q simple_sitemap; then
    echo "  > Generate sitemap."
    $drush simple-sitemap:generate
  fi
else
  echo "  > Skipped creation of generated content."
fi
