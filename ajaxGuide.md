# Ajax POST JSON subpages available in SayBale
| SUBPAGES (Ajax) | ARGUMENT KEYS | RETURN KEYS        |
|-----------------|---------------|--------------------|
| disconnect      | reason        |                    |
| connect         | nick          |                    |
| sendchat        | text          |                    |
| getchat         |               | logs next continue |
| setnick         | newNick       | continue           |
| adminauth       | password      | success            |
| kick            | other         | success            |
| kickban         | banIP         | success            |
| unban           | banIP         | success            |
| getips          | nickname      | success ips        |
| userlist        |               | users admins       |

# Notes
## getchat
- `next` is the time recommended until the next `../getchat` query. 
- `logs` may contain formatting which is resolved by client.js in the SayBale website, but it can be ignored.

## adminauth
- `password` is always a SHA256 hash of the actual password.

## kick
- `other` is the nickname of the (un)desired user.