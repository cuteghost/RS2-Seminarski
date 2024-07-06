# eBooking - Seminarski Razvoj Softvera 2

## Domains
All of the microservices are assigned to a domain. Every request goes through the nginx which acts as a loadbalancer in-front of the APIs. Nginx strips SSL certificate and routes unencrypted traffic to APIs.

The domains used are as follow:

- ebooking.api.cuteghost.online - Main API
- messenger.cuteghost.online - Messenger API
- payment.cuteghost.online - Payment App

## Credentials

### Desktop App (Administrator Role)
- Email: admin@ebooking.com
- Password: Stringst

### Mobile App (Customer Role)
- Email: dea@email.com
- Password: Stringst

### Mobile App (Partner Role)
- Email: dude@email.com
- Password: Stringst

## OAuth Testing

To test OAuth with Google and Facebook use following credentials:
### Google

- Email: razvojsoftveradva@gmail.com
- Password: Stringst  

### Facebook

- Email: razvojsoftverafacebook@gmail.com
- Password: Stringst

## Payment Testing
- Credit Card Number: 4032 0350 3641 8515
- Expiry Date: 08/2025
- CVC Code: 885

Rest of the data fields can be dummy data.

After successful reservation head to https://www.sandbox.paypal.com/signin and signin using following credentials:

- Email: sb-ychoj31063636@business.example.com
- Password: 8&@nB?bz

After each reservation the amount should be reflected on the account.

## Google Maps Testing (Nearby Accommodations)
On mobile device(Emulator) set the location of the device to be Sarajevo. That way the Nearby Accommodations feature will find all the accommodations that are in close proximity(10 kilometers).



## RabbitMQ Testing

To test RabbitMQ implementation use Customer account to make a reservation. After reservation is made the automatic Welcome message is sent from Owner(Partner) to the Customer.


