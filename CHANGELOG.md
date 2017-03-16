# Change Log
All notable changes to this project will be documented in this file.

## [Unreleased]

## [2017-03-15]
### Added
- Caching headers to API responses ([#395](https://github.com/18F/crime-data-api/issues/395))
- National participation endpoint ([#415](https://github.com/18F/crime-data-api/pull/415))

### Changed
- Reorder columns in agency participation CSV ([#414](https://github.com/18F/crime-data-api/pull/414))

### Fixed
- Arson data included in summary data ([#399](https://github.com/18F/crime-data-api/issues/399))
- Fix "R" and "U" offender relationship values ([#408](https://github.com/18F/crime-data-api/issues/408))
- Recompute state and county populations using ref_agency_population ([#412](https://github.com/18F/crime-data-api/issues/412))
- Rebuild participation table with the same renaming strategy as `reta_month_offense_subcat_summary` ([#417](https://github.com/18F/crime-data-api/issues/417))
- Participation table also computes covered population for NIBRS ([](https://github.com/18F/crime-data-api/issues/419))
- National endpoint returns aggregated data ([#420](https://github.com/18F/crime-data-api/issues/420))
