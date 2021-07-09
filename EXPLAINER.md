# Reporting API #
The Reporting API is a mechanism for web servers to tell browsers where to send errors and other information about a browsing session.  This explainer summarizes the basic usage.  For details see the [Reporting API specification](http://wicg.github.io/reporting/) and the specifications of other features that use the Reporting API such as [Content Security Policy](https://w3c.github.io/webappsec-csp/#reporting), [Deprecation Reports](https://wicg.github.io/deprecation-reporting/), or [Cross-origin Opener Policy](https://github.com/camillelamy/explainers/blob/master/coop_reporting.md).

## The problem ##
When a web application encounters some error or potential problem it is important that the application author have some mechanism to be made aware of that error.  Common errors such as unhandled JavaScript exceptions can be observed in script.  But other errors may occur when it's not possible to rely on running script (such as a browser crash, or a Content Security Policy violation that prevents the page from being loaded).  The Reporting API provides a generic mechanism for a browser to report errors back to an HTTP Server in an out-of-band fashion.

## Enabling reporting ##
Reporting is enabled by specifying a `Reporting-Endpoints` header in the HTTP response, eg:
```http
Reporting-Endpoints: default="https://example.com/reports"
```
The header defines the names for each reporting endpoint. Different features have different ways of specifying which reporting endpoint to use for particular reports. Some, like CSP, use a `report-to` parameter; others, such as deprecation reports, use the `default` endpoint if it is specified.

When reports are generated they are cached for a short time and then sent to the appropriate endpoint, which will receive an HTTP `POST` request with JSON-formatted body containing an array of reports, eg:
```http
POST /reports HTTP/1.1
Host: example.com
...
Content-Type: application/reports+json

[{
  "type": "myreport",
  "age": 10,
  "url": "https://example.com/originatingpage/",
  "user_agent": "FooBrowser/1.0 (KHTML, sorta like Gecko)",
  "body": {
...
  }
}]
```

Each report has: 
 - `type`: a string that indicates the category of report.
 - `age`: the number of seconds between when the report was triggered and when it was sent.
 - `url`: the URL of the page which triggered the report.
 - `user_agent`: the reporting browser's user agent.
 - `body`: the contents of the report as defined by the `type`.

## Example report: Deprecations ##
Some report types are defined which are always enabled (and sent to the `default` reporting [group](http://wicg.github.io/reporting/#id-member)).
[Deprecation Reports](https://wicg.github.io/deprecation-reporting/) are reports indicating that a browser API or feature has been used which is expected to stop working in a future update to the browser.  For example:

```json
{
  "type": "deprecation",
  "age": 10,
  "url": "https://example.com/",
  "user_agent": "BarBrowser/98.0 (Mozilla/5.0 compatiblish)",
  "body": {
    "id": "websql", 
    "anticipatedRemoval": "1/1/2020", 
    "message": "WebSQL is deprecated and will be removed in Chrome 97 around January 2020",
    "sourceFile": "https://example.com/index.js",
    "lineNumber": 1234,
    "columnNumber": 42
  }
}
```

The report body has the following properties:
- `id` (required): an implementation-defined string identifying the feature or API that will be removed.  This string can be used for grouping and counting related reports.
- `anticipatedRemoval`: A date indicating roughly when the browser version without the specified API will be generally available (excluding "beta" or other pre-release channels).  This value should be used to sort or prioritize warnings.  When omitted the deprecation should be considered low priority (removal may not actually occur).  
- `message`: A developer-readable message with details (typically matching what would be displayed on the developer console).  The message is not guaranteed to be unique for a given `id` (eg. it may contain additional context on how the API was used).
- `sourceFile`: If known, the file which first used the indicated API
- `lineNumber`: if known, the line number in `sourceFile` where the indicated API was first used.
- `columnNumber`: if known, the column number in `sourceFile` where the indicated API was first used.


## ReportingObserver - Observing reports from JavaScript
In addition to (or even instead of) having reports delivered to an endpoint, it can be convenient to be informed of reports from within the page's JavaScript (eg. for analytics libraries which have no way to influence HTTP headers).  This doesn't make sense or isn't possible for all reports (eg. crashes), but is most useful for reports generated as a direct result of something the page's script has done (such as a deprecation warning).

```javascript
function onReport(reports, observer) {
  for(let report of reports) {
    if (report.type == "deprecation") {
      sendDeprecationAnalytics(JSON.stringify(report.body));
    }
  }
}

let observer = new ReportingObserver(onReport);
observer.observe();
```

Shortly after a report corresponding to a given JavaScript context is generated (even if there are no endpoints registered), all `ReportingObserver` callback functions in that context are invoked with a copy of the report as a JavaScript object.  Since the exact details of reports can vary from one browser to another, applications generally should not change their behavior based on the presence or contents of a report, but use this API only for analytics purposes.
