$TTL 3600
@	IN	SOA	@	ns1.dropbox.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.dropbox.com.
@	IN	MX	10	dropbox.com.
@	IN	A		180.1.1.100	
mail	IN	A		180.1.1.100
www	IN	A		180.1.1.100
ns1	IN	A		198.41.0.4
