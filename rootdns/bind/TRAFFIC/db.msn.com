$TTL 3600
@	IN	SOA	@	ns1.msn.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.msn.com.
@	IN	MX	10	msn.com.
@	IN	A		72.32.4.26
mail	IN	A		72.32.4.26
www	IN	A		72.32.4.26
ns1	IN	A		198.41.0.4
