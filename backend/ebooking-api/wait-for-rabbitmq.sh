#!/bin/sh

# RabbitMQ host and port
RABBITMQ_HOST=rabbitmq
RABBITMQ_PORT=5672

echo "Waiting for RabbitMQ at $RABBITMQ_HOST:$RABBITMQ_PORT"

# Wait for RabbitMQ to be available
while ! nc -z $RABBITMQ_HOST $RABBITMQ_PORT; do
  sleep 1
done

echo "RabbitMQ started"

# Execute the main container command
exec dotnet Messenger.dll