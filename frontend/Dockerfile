FROM nginx:alpine

COPY ./html /usr/share/nginx/html

COPY ./conf.d/ /etc/nginx/conf.d/

EXPOSE 3000

# Start nginx
CMD ["nginx", "-g", "daemon off;"]