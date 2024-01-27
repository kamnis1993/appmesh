# Use the official Nginx base image
FROM nginx:latest

# Copy custom configuration file to the container
COPY nginx.conf /etc/nginx/nginx.conf

# Copy your web application files to the default Nginx document root
COPY html/ /usr/share/nginx/html/

# Expose port 80 for incoming traffic
EXPOSE 80

# Command to start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]

