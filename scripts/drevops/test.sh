#!/usr/bin/env bash
# shellcheck disable=SC2086
# shellcheck disable=SC2015
##
# Run tests.
#
# Usage:
# Run all tests:
# ./test.sh
#
# Run unit tests:
# DREVOPS_TEST_TYPE=unit ./test.sh
#
# Run kernel tests:
# DREVOPS_TEST_TYPE=kernel ./test.sh
#
# Run functional tests:
# DREVOPS_TEST_TYPE=functional ./test.sh
#
# Run bdd tests:
# DREVOPS_TEST_TYPE=bdd ./test.sh
#
# Run specific tags (eg: content_type) bdd tests:
# DREVOPS_TEST_TYPE=bdd DREVOPS_TEST_BEHAT_TAGS=content_type ./test.sh

set -e
[ -n "${DREVOPS_DEBUG}" ] && set -x

# Flag to allow Unit tests to fail.
DREVOPS_TEST_UNIT_ALLOW_FAILURE="${DREVOPS_TEST_UNIT_ALLOW_FAILURE:-0}"

# Group to run Unit tests.
DREVOPS_TEST_UNIT_GROUP="${DREVOPS_TEST_UNIT_GROUP:-site:unit}"

# Flag to allow Kernel tests to fail.
DREVOPS_TEST_KERNEL_ALLOW_FAILURE="${DREVOPS_TEST_KERNEL_ALLOW_FAILURE:-0}"

# Group to run Kernel tests.
DREVOPS_TEST_KERNEL_GROUP="${DREVOPS_TEST_KERNEL_GROUP:-site:kernel}"

# Flag to allow Functional tests to fail.
DREVOPS_TEST_FUNCTIONAL_ALLOW_FAILURE="${DREVOPS_TEST_FUNCTIONAL_ALLOW_FAILURE:-0}"

# Group to run Functional tests.
DREVOPS_TEST_FUNCTIONAL_GROUP="${DREVOPS_TEST_FUNCTIONAL_GROUP:-site:functional}"

# Flag to allow BDD tests to fail.
DREVOPS_TEST_BDD_ALLOW_FAILURE="${DREVOPS_TEST_BDD_ALLOW_FAILURE:-0}"

# Directory to store test result files.
DREVOPS_TEST_REPORTS_DIR="${DREVOPS_TEST_REPORTS_DIR:-}"

# Directory to store test artifact files.
DREVOPS_TEST_ARTIFACT_DIR="${DREVOPS_TEST_ARTIFACT_DIR:-}"

# Behat profile name. Optional. Defaults to "default".
DREVOPS_TEST_BEHAT_PROFILE="${DREVOPS_TEST_BEHAT_PROFILE:-default}"

# Behat format. Optional. Defaults to "pretty".
DREVOPS_TEST_BEHAT_FORMAT="${DREVOPS_TEST_BEHAT_FORMAT:-pretty}"

# Behat tags. Optional. Default runs all tests.
DREVOPS_TEST_BEHAT_TAGS="${DREVOPS_TEST_BEHAT_TAGS:-}"

# Behat test runner index. If is set  - the value is used as a suffix for the
# parallel Behat profile name (e.g., p0, p1).
DREVOPS_TEST_BEHAT_PARALLEL_INDEX="${DREVOPS_TEST_BEHAT_PARALLEL_INDEX:-}"

# ------------------------------------------------------------------------------

# Get test type or fallback to defaults.
DREVOPS_TEST_TYPE="${DREVOPS_TEST_TYPE:-unit-kernel-functional-bdd}"

# Create test reports and artifact directories.
[ -n "${DREVOPS_TEST_REPORTS_DIR}" ] && mkdir -p "${DREVOPS_TEST_REPORTS_DIR}"
[ -n "${DREVOPS_TEST_ARTIFACT_DIR}" ] && mkdir -p "${DREVOPS_TEST_ARTIFACT_DIR}"

if [ -z "${DREVOPS_TEST_TYPE##*fe*}" ] && [ -n "${DREVOPS_DRUPAL_THEME}" ]; then
  echo "==> Run front-end tests."
  if [ -d "docroot/themes/contrib/${DREVOPS_DRUPAL_THEME}/civictheme_library/node_modules" ]; then
    npm run --prefix "docroot/themes/contrib/${DREVOPS_DRUPAL_THEME}/civictheme_library" test || \
    [ "${DREVOPS_TEST_FE_ALLOW_FAILURE}" -eq 1 ]
  fi
else
  echo "==> Skipped front-end tests."
fi

if [ ! -d "/app/vendor" ]; then
  echo "==> Skipped PHP tests."
  exit 0
fi

if [ -z "${DREVOPS_TEST_TYPE##*unit*}" ]; then
  echo "==> Run unit tests."

  # Generic tests that do not require Drupal bootstrap.
  phpunit_opts=()
  [ -n "${DREVOPS_TEST_REPORTS_DIR}" ] && phpunit_opts+=(--log-junit "${DREVOPS_TEST_REPORTS_DIR}"/phpunit/unit.xml)
  vendor/bin/phpunit "${phpunit_opts[@]:-}" tests/phpunit --group "${DREVOPS_TEST_UNIT_GROUP}" "$@" \
  || [ "${DREVOPS_TEST_UNIT_ALLOW_FAILURE}" -eq 1 ]

  # Custom modules tests that require Drupal bootstrap.
  phpunit_opts=(-c /app/docroot/core/phpunit.xml.dist)
  [ -n "${DREVOPS_TEST_REPORTS_DIR}" ] && phpunit_opts+=(--log-junit "${DREVOPS_TEST_REPORTS_DIR}"/phpunit/unit_modules.xml)
  vendor/bin/phpunit "${phpunit_opts[@]}" docroot/modules/custom --group "${DREVOPS_TEST_UNIT_GROUP}" "$@" \
  || [ "${DREVOPS_TEST_UNIT_ALLOW_FAILURE}" -eq 1 ]

  # Custom theme tests that require Drupal bootstrap.
  if [ -n "${DREVOPS_DRUPAL_THEME}" ]; then
    phpunit_opts=(-c /app/docroot/core/phpunit.xml.dist)
    [ -n "${DREVOPS_TEST_REPORTS_DIR}" ] && phpunit_opts+=(--log-junit "${DREVOPS_TEST_REPORTS_DIR}"/phpunit/unit_themes.xml)
    vendor/bin/phpunit "${phpunit_opts[@]}" "docroot/themes/contrib/${DREVOPS_DRUPAL_THEME}" --group "${DREVOPS_TEST_UNIT_GROUP}" "$@" \
    || [ "${DREVOPS_TEST_UNIT_ALLOW_FAILURE}" -eq 1 ]
  fi
fi

if [ -z "${DREVOPS_TEST_TYPE##*kernel*}" ]; then
  echo "==> Run Kernel tests"

  phpunit_opts=(-c /app/docroot/core/phpunit.xml.dist)
  [ -n "${DREVOPS_TEST_REPORTS_DIR}" ] && phpunit_opts+=(--log-junit "${DREVOPS_TEST_REPORTS_DIR}"/phpunit/kernel.xml)

  vendor/bin/phpunit "${phpunit_opts[@]}" docroot/modules/custom --group "${DREVOPS_TEST_KERNEL_GROUP}" "$@" \
  || [ "${DREVOPS_TEST_KERNEL_ALLOW_FAILURE:-0}" -eq 1 ]
fi

if [ -z "${DREVOPS_TEST_TYPE##*functional*}" ]; then
  echo "==> Run Functional tests"

  phpunit_opts=(-c /app/docroot/core/phpunit.xml.dist)
  [ -n "${DREVOPS_TEST_REPORTS_DIR}" ] && phpunit_opts+=(--log-junit "${DREVOPS_TEST_REPORTS_DIR}"/phpunit/functional.xml)

  vendor/bin/phpunit "${phpunit_opts[@]}" docroot/modules/custom --group "${DREVOPS_TEST_FUNCTIONAL_GROUP}" "$@" \
  || [ "${DREVOPS_TEST_FUNCTIONAL_ALLOW_FAILURE:-0}" -eq 1 ]

  if [ -n "${DREVOPS_DRUPAL_THEME}" ]; then
    vendor/bin/phpunit "${phpunit_opts[@]}" "docroot/themes/contrib/${DREVOPS_DRUPAL_THEME}" --group "${DREVOPS_TEST_FUNCTIONAL_GROUP}" "$@" \
    || [ "${DREVOPS_TEST_FUNCTIONAL_ALLOW_FAILURE:-0}" -eq 1 ]
  fi
fi

if [ -z "${DREVOPS_TEST_TYPE##*bdd*}" ]; then
  echo "==> Run BDD tests."

  # Use parallel Behat profile if using more than a single node to run tests.
  if [ -n "${DREVOPS_TEST_BEHAT_PARALLEL_INDEX}" ] ; then
    DREVOPS_TEST_BEHAT_PROFILE="${DREVOPS_TEST_BEHAT_PROFILE:-p}${DREVOPS_TEST_BEHAT_PARALLEL_INDEX}"
    echo "==> Running using profile \"${DREVOPS_TEST_BEHAT_PROFILE}\"."
  fi

  [ -n "${DREVOPS_TEST_ARTIFACT_DIR}" ] && export BEHAT_SCREENSHOT_DIR="${DREVOPS_TEST_ARTIFACT_DIR}/screenshots"

  behat_opts=(
    --strict
    --colors
    --profile="${DREVOPS_TEST_BEHAT_PROFILE}"
    --format="${DREVOPS_TEST_BEHAT_FORMAT}"
    --out std
  )

  # Run specific Behat tests.
  if [ -n "${DREVOPS_TEST_BEHAT_TAGS}" ]; then
    behat_opts+=(--tags=${DREVOPS_TEST_BEHAT_TAGS})
  fi

  [ -n "${DREVOPS_TEST_REPORTS_DIR}" ] && behat_opts+=(--format "junit" --out "${DREVOPS_TEST_REPORTS_DIR}"/behat)

  vendor/bin/behat "${behat_opts[@]}" "$@" \
  || ( [ -n "${CI}" ] && vendor/bin/behat "${behat_opts[@]}" --rerun "$@" ) \
  || [ "${DREVOPS_TEST_BDD_ALLOW_FAILURE}" -eq 1 ]
fi
