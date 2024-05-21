All api endpoints start with /api
localhost:8000/api
### Without **token** 

| route     | arguments           | returns                 |
| --------- | ------------------- | ----------------------- |
| /register | POST email,password | success or not          |
| /login    | POST email,password | on success return token |
So this would be `localhot:8000/api/login` and 
`localhot:8000/api/register`

---
### With token - all api requests to have 'token' argument, containing login token

### User
**baseURL** - /api/

| Route | Arguments         | Returns                                         |
| ----- | ----------------- | ----------------------------------------------- |
| /user | GET               | returns user information                        |
| /save | POST score, coins | Saves user score, and adds coins to the account |

### Stats 
**baseURL** - /api/stats

| Route | arguments | returns                                                                                              |
| ----- | --------- | ---------------------------------------------------------------------------------------------------- |
| /     | GET       | Returns users stats, **skin_id can be null, that means we need to apply default skin to the player** |


### Shop
**baseURL** - /api/shop

| Route    | arguments         | returns                                                                                                        |
| -------- | ----------------- | -------------------------------------------------------------------------------------------------------------- |
| /        | GET               | Returns users shop, current upgrades and prices                                                                |
| /upgrade | POST upgrade_name | Upgrades item that was named, you can get item names from the `GET /` return array                             |
| /skin    | POST skin_name    | Buys a skin with provided `skin_name`, skin_names are provided in `database/seeders/DatabaseSeeder.php` file   |
| /equip   | POST skin_name    | Equips a skin with provided `skin_name`, skin_names are provided in `database/seeders/DatabaseSeeder.php` file |


### Stripe payment

|Full link|In browser|
|----|----|
|http://localhost:8000/stripe/buy/{user_token}| In browser redirects to stripe payment, if payment is successful, then user will recieve 10000 in game currency|


