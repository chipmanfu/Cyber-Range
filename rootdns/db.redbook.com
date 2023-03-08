$TTL 3600
@	IN	SOA	@	ns1.redbook.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.redbook.com.
@	IN	MX	10	redbook.com.
@	IN	A		180.1.1.120
mail	IN	A		180.1.1.120
www	IN	A		180.1.1.120
ns1	IN	A		198.41.0.4
