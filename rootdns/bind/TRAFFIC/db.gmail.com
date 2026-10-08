;Traffic-SMTP
$TTL 3600
@	IN	SOA	@	ns1.gmail.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.gmail.com.
@	IN	NS		ns2.gmail.com.
@	IN	MX	10	gmail.com.
@	IN	A		92.107.127.12
@	IN	TXT	"v=spf1 mx -all"
@	IN	TXT	"v=DMARC1; p=none; rua=mailto:dmarc@gmail.com"
mail	IN	A		92.107.127.12
www	IN	A		92.107.127.12
ns1	IN	A		198.41.0.4
ns2	IN	A		192.5.5.241
