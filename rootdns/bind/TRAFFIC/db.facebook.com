;Traffic-SMTP
$TTL 3600
@	IN	SOA	@	ns1.facebook.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.facebook.com.
@	IN	NS		ns2.facebook.com.
@	IN	MX	10	facebook.com.
@	IN	A		188.65.120.83
@	IN	TXT	"v=spf1 mx -all"
@	IN	TXT	"v=DMARC1; p=none; rua=mailto:dmarc@facebook.com"
mail	IN	A		188.65.120.83
www	IN	A		188.65.120.83
ns1	IN	A		198.41.0.4
ns2	IN	A		192.5.5.241
