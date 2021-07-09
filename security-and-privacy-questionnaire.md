# [Self-Review Questionnaire: Security and Privacy](https://w3ctag.github.io/security-questionnaire/)

For further explanation see [the full questionnaire](https://w3ctag.github.io/security-questionnaire/).

01. What information might this feature expose to Web sites or other parties,
    and for what purposes is that exposure necessary?

The purpose of the Reporting API is to collect information about events occurring within a page, 
about failures related to performance, the site's development, security feature deployments, etc.,
and delivering those to an endpoint. These are collected from users "in the wild", rather than
from testers "in the lab", as users typically exercising more parts of a site than testing
infrastructure does, with a variety of interactions and devices which the lab can't match.

02. Is this specification exposing the minimum amount of information necessary
    to power its features?

Besides the user agent, and the url the user is interacting with, both of which are available to
any running scripts on the page, this specification does not prescribe any particular other pieces
of information to be included in a report. That is left to other specifications which integrate
with this one, which define the structure of their reports and the events which trigger their
sending.

03. How does this specification deal with personal information,
    personally-identifiable information (PII), or information derived from
    them?

The Reporting API can potentially expose a user's IP address to a third-party server, though this
is exactly the same as existing capabilities with subresource fetching. Since the IP or other
network addressing data which was valid when a report was generated may be sensitive, or may
identify the user or expose their behavior after they have chosen to switch to a different
network connection, the specification suggests that those reports may be dropped if the network
changes. It does yet not go as far as requiring this, as the current state is no different than
other beacons.

04. How does this specification deal with sensitive information?

See above, generally.

05. Does this specification introduce new state for an origin that persists
    across browsing sessions?

The Reporting API does not. The portions of this specification which did that at one point have
been split into a separate specification (Network Reporting), and have been removed from this one.

06. Does this specification expose information about the underlying
    platform to origins?

No, the Reporting API does not. It would be possible for a feature integrating with Reporting to
expose such information, but that would be an issue for that feature.

07. Does this specification allow an origin access to sensors on a user’s
    device?

No.

08. What data does this specification expose to an origin?  Please also
    document what data is identical to data exposed by other features, in the
    same or different contexts.

The Reporting API on its own exposes a users IP address and User Agent string to reporting
endpoints, within the report body. This is identical to data exposed through mechanisms such as
subresource fetching, XHR, or `navigator.sendBeacon`. Other specifications which integrate with
Reporting will add more information to specific reports, but they should be subject to their own
privacy and security review.

09. Does this specification enable new script execution/loading mechanisms?

No.

10. Does this specification allow an origin to access other devices?

No.

11. Does this specification allow an origin some measure of control over a user
    agent's native UI?

No.

12. What temporary identifiers might this specification create or expose
    to the web?

None.

13. How does this specification distinguish between behavior in first-party and
    third-party contexts?

The specification allows reporting endpoints to be declared which are third-party to the
page which declares them. This allows an ecosystem of third-party report analysis services,
and opens the possibility of report aggregators and anonymizers, which are separate from
the sites where the reports are generated. In this scenario, the Reporting API insists
that the remote endpoint follow the CORS protocol, and additionally, any credentials are
stripped from the outgoing requests, so that users cannot be tracked across sites through
a reporting endpoint.

14. How does this specification work in the context of a user agent’s Private
    Browsing or "incognito" mode?

This is not covered by the specification at all. In practice, the mechanism will continue
to operate in incognito mode, but there will be no credentials available to send, unless
the user has chosen to sign in while in incognito. Additionally, reports generated from an
incognito mode window will not be sent in the same request as those generated in other
windows, even when they are destined for the same endpoint.

15. Does this specification have both "Security Considerations" and "Privacy
    Considerations" sections?

Yes. See [Security Considerations](https://w3c.github.io/reporting/#security) and
[Privacy Considerations](https://w3c.github.io/reporting/#privacy).

16. Does this specification allow downgrading default security characteristics?

No.

17. What should this questionnaire have asked?

¯\\\_(ツ)\_/¯
