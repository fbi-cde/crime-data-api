# Change Log
All notable changes to this project will be documented in this file.

## [2017-04-26]
### Added
- Create new denormalized table for agency annual counts ([#455](https://github.com/18F/crime-data-api/pull/455))
- Load estimated data ([#469](https://github.com/18F/crime-data-api/pull/469))

### Changed
- Close off every database connection at the end of a transaction ([#470](https://github.com/18F/crime-data-api/pull/470))


## [2017-04-12]
### Added
- Include API introduction text in Swagger documentation ([#461](https://github.com/18F/crime-data-api/pull/461))

### Changed
- Restore `/agencies` and `/agencies/:ori` endpoints ([#452](https://github.com/18F/crime-data-api/pull/452))

### Removed
- Removed unused code in `CdeNibrsIncident` and `CdeRetaMonth` classes ([#441](https://github.com/18F/crime-data-api/pull/441/files))
- Remove `/geo/states/<state_abbr>/participation` and `/incidents/count` endpoints ([#463](https://github.com/18F/crime-data-api/pull/463))


## [2017-03-29]
### Added
- Alias the `/incidents/count` endpoint to `/counts` ([#281](https://github.com/18F/crime-data-api/issues/281))
- Allow api key via the X-API-KEY HTTP header ([#434](https://github.com/18F/crime-data-api/issues/434))
- Add new `/participation` endpoints for consistency ([#440](https://github.com/18F/crime-data-api/pull/440))

### Changed
- Do not generate `swagger.json` to give more control over API documentation ([#435](https://github.com/18F/crime-data-api/pull/435))

### Fixed
- Show `/codes` endpoint in Swagger ([#196](https://github.com/18F/crime-data-api/issues/196))
- Pagination parameters should not exceed total pages ([#336](https://github.com/18F/crime-data-api/issues/336))
- Remove duplicate variable parameters for count endpoints ([#382](https://github.com/18F/crime-data-api/issues/382))
- Use state postal abbreviation for `/offender/offense` endpoint ([#403](https://github.com/18F/crime-data-api/issues/403))


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
