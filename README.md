# CivicTheme - Development source site
Mono-repo used to maintain CivicTheme and accompanying modules that are automatically published to another repositories on release.

[![CircleCI](https://circleci.com/gh/salsadigitalauorg/civictheme_source.svg?style=shield)](https://circleci.com/gh/salsadigitalauorg/civictheme_source)
![Drupal 9](https://img.shields.io/badge/Drupal-9-blue.svg)

[//]: # (DO NOT REMOVE THE BADGE BELOW. IT IS USED BY DREVOPS TO TRACK INTEGRATION)

[![DrevOps](https://img.shields.io/badge/DrevOps-9.x-blue.svg)](https://github.com/drevops/drevops/tree/9.x)

## Environments

- [PROD](https://default.civictheme.io)
- [DEV](https://defaultdev.civictheme.io)
- [LOCAL](http://civictheme-source.docker.amazee.io/)

### Content profiles

- [Corporate](https://nginx-php.content-corporate.civictheme-source.lagoon.salsa.hosting/)
- [Government](https://nginx-php.content-government.civictheme-source.lagoon.salsa.hosting/)
- [Higher Education](https://nginx-php.content-highereducation.civictheme-source.lagoon.salsa.hosting/)

## Local environment setup
- Make sure that you have latest versions of all required software installed:
  - [Docker](https://www.docker.com/)
  - [Pygmy](https://github.com/pygmystack/pygmy)
  - [Ahoy](https://github.com/ahoy-cli/ahoy)
- Make sure that all local web development services are shut down (Apache/Nginx, Mysql, MAMP etc).
- Checkout project repository (in one of the [supported Docker directories](https://docs.docker.com/docker-for-mac/osxfs/#access-control)).
- `pygmy up`
- `ahoy build`

### Apple M1 adjustments

Copy `default.docker-compose.override.yml` to `docker-compose.override.yml`.

## Development

Please refer to [development documentation](DEVELOPMENT.md).

## Testing

Please refer to [testing documentation](TESTING.md).

## CI

Please refer to [CI documentation](CI.md).

## Deployment

Please refer to [deployment documentation](DEPLOYMENT.md).

## Releasing

Please refer to [releasing documentation](RELEASING.md).

## FAQs

Please refer to [FAQs](FAQs.md).

## More about CivicTheme

- [CivicTheme UI kit](https://github.com/salsadigitalauorg/civictheme_library)
- [CivicTheme Drupal theme](https://github.com/salsadigitalauorg/civictheme)
- [Default content for CivicTheme](https://github.com/salsadigitalauorg/civictheme_content)
- [Admin adjustments for CivicTheme Drupal theme](https://github.com/salsadigitalauorg/civictheme_admin)
- [GovCMS adjustments for CivicTheme Drupal theme](https://github.com/salsadigitalauorg/civictheme_govcms)

---

For additional information, please refer to the [Documentation site](https://docs.civictheme.io/)
