;Traffic-SMTP
$TTL 3600
@	IN	SOA	@	ns1.linkedln.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.linkedln.com.
@	IN	NS		ns2.linkedln.com.
@	IN	MX	10	linkedln.com.
@	IN	A		70.32.91.153
@	IN	TXT	"v=spf1 mx -all"
@	IN	TXT	"v=DMARC1; p=none; rua=mailto:dmarc@linkedln.com"
mail	IN	A		70.32.91.153
www	IN	A		70.32.91.153
ns1	IN	A		198.41.0.4
ns2	IN	A		192.5.5.241
