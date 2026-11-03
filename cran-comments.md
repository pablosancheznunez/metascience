## Submission

First submission of metascience.

## Test environments

* GitHub Actions: Ubuntu (R devel, release, oldrel-1), macOS (release), Windows (release).
* Local: Windows 11 x64, R 4.6.2 ucrt.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Notes for CRAN

* The package makes no network requests.
* `ms_app()` needs the suggested package shiny; its example runs only in interactive sessions. The tests of the interface modules skip the sections whose optional packages are not installed.
* Examples and tests write only to `tempdir()`.
