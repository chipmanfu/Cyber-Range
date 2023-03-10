FROM rlister/hastebin
COPY jquery.min.js /app/static/
RUN sed -i 's/https:\/\/ajax.googleapis.com\/ajax\/libs\/jquery\/1.7.1\///g' /app/static/index.html
