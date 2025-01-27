#!/usr/bin/env bash
##
# Optionally install and activate a sub-theme.
#
# shellcheck disable=SC2086

set -e
[ -n "${DREVOPS_DEBUG}" ] && set -x

# Path to the application.
APP="${APP:-/app}"

# ------------------------------------------------------------------------------

[ "${CIVICTHEME_SUBTHEME_ACTIVATION_SKIP}" = "1" ] && echo "Skipping sub-theme activation" && return

# Use local or global Drush, giving priority to a local drush.
drush="$(if [ -f "${APP}/vendor/bin/drush" ]; then echo "${APP}/vendor/bin/drush"; else command -v drush; fi)"

if [ ! -d $APP/docroot/themes/custom/civictheme_demo ]; then
  echo "  > Creating civictheme_demo subtheme."
  pushd $APP/docroot/themes/contrib/civictheme >/dev/null || exit 1
  php civictheme_create_subtheme.php civictheme_demo "CivicTheme Demo" "Demo sub-theme for a CivicTheme theme."
  [ ! -d $APP/docroot/themes/custom/civictheme_demo ] && echo "ERROR: Failed to create civictheme_demo sub-theme." && exit 1
fi

echo "  > Installing civictheme_demo theme."
$drush theme:enable civictheme_demo -y

echo "  > Setting civictheme_demo as a default theme."
$drush config-set system.theme default civictheme_demo -y

if [ "$CIVICTHEME_SUBTHEME_FE_SKIP" != "1" ] && command -v npm &> /dev/null; then
  pushd $APP/docroot/themes/custom/civictheme_demo >/dev/null || exit 1

  if [ ! -d $APP/docroot/themes/custom/civictheme_demo/node_modules ]; then
    echo "  > Installing FE dependencies."
    npm install
  fi

  echo "  > Building FE assets."
  npm run build

  popd >/dev/null || exit 1
fi
