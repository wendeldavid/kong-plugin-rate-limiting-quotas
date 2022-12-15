
# Rate Limiting

Rate limit how many HTTP requests can be made in a given period of seconds, minutes, hours, days, months, or years.

If the underlying Service/Route (or deprecated API entity) has no authentication layer, the **Client IP** address will be used; otherwise, the Consumer will be used if an authentication plugin has been configured.

## Configuration Reference

Configuration Reference
This plugin is **partially compatible** with DB-less mode.

In DB-less mode, you configure Kong Gateway declaratively. Therefore, the Admin API is mostly read-only. The only tasks it can perform are all related to handling the declarative config, including:

* Setting a target's health status in the load balancer
* Validating configurations against schemas
* Uploading the declarative configuration using the `/config` endpoint

The plugin will run fine with the `local` policy (which doesn’t use the database) or the `redis` policy (which uses an independent Redis, so it is compatible with DB-less).

The plugin will not work with the `cluster` policy, which requires writes to the database.

### Example plugin configuration

The plugin will run fine with the `local` policy (which doesn't use the database) or the `redis` policy (which uses an independent Redis, so it is compatible with DB-less).

The plugin will not work with the `cluster` policy, which requires writes to the database.

| form parameter | descrption | type | required | default value |
|----------------|------------|------|----------|---------------|
| `name` | The name of the plugin, in this case `rate-limiting-quotas` | string | true | |
| `service.name` or `service.id` | The name or ID of the service the plugin targets. Set one of these parameters if adding the plugin to a service through the top-level `/plugins` endpoint. Not required if using `/services/SERVICE_NAME\|SERVICE_ID/plugins` | string | false | |
| `route.name` or `route.id` | The name or ID of the route the plugin targets. Set one of these parameters if adding the plugin to a route through the top-level `/plugins `endpoint. Not required if using `/routes/ROUTE_NAME\|ROUTE_ID/plugins` | string | false | |
| `consumer.name` or `consumer.id` | The name or ID of the consumer the plugin targets. Set one of these parameters if adding the plugin to a consumer through the top-level `/plugins` endpoint. Not required if using `/consumers/CONSUMER_NAME\|CONSUMER_ID/plugins` | string | false | |
| `enabled` | Whether this plugin will be applied | boolean | false | true |
| `config.second` | The number of HTTP requests that can be made per second. It is a fallback of the `quotas` config | number | semi | |
| `config.minute` | The number of HTTP requests that can be made per minute. It is a fallback of the `quotas` config | number | semi | |
| `config.hour` |The number of HTTP requests that can be made per hour. It is a fallback of the `quotas` config | number | semi | |
| `config.day` |The number of HTTP requests that can be made per day. It is a fallback of the `quotas` config | number | semi | |
| `config.month` | The number of HTTP requests that can be made per month. It is a fallback of the `quotas` config | number | semi | |
| `config.year` | The number of HTTP requests that can be made per year. It is a fallback of the `quotas` config | number | semi | |
| `config.quotas.second` | Array with comma separated ACL and value number of HTTP requests that can be made per second. Ex: `acl1,acl2:10` | array | semi | |
| `config.quotas.minute` | Array with comma separated ACL and value  number of HTTP requests that can be made per minute. Ex: `acl1,acl2:10` | array | semi | |
| `config.quotas.hour` | Array with comma separated ACL and value number of HTTP requests that can be made per hour. Ex: `acl1,acl2:10` | array | semi | |
| `config.quotas.day` | Array with comma separated ACL and value number of HTTP requests that can be made per day. Ex: `acl1,acl2:10` | array | semi | |
| `config.quotas.month` | Array with comma separated ACL and value number of HTTP requests that can be made per month. Ex: `acl1,acl2:10` | array | semi | |
| `config.quotas.year` | Array with comma separated ACL and value number of HTTP requests that can be made per year. Ex: `acl1,acl2:10` | array | semi | |
| `config.limit_by` | The entity that is used when aggregating the limits. Available  values are:<br> - `consumer`<br>- `credential`<br>- `ip`<br>- `service` (The `service.id` or `service.name` configuration must be provided if you're adding the plugin to a service through the top-level `/plugins` endpoint.)<br>- `header` (The `header_name` configuration must be provided.)<br>- `path` (The `path` configuration must be provided.)<br><br>If the entity value for aggregating the limits cannot be determined, the system falls back to `ip` | string | false | `consumer` |
| `config.header_name` | Header name to be used if `limit_by` is set to `header` | string | semi | |
| `config.path` | Path to be used if `limit_by` is set to `path` | string | semi | |
| `config.policy` | The rate-limiting policies to use for retrieving and incrementing the limits. Available values are:<br>- `local`: Counters are stored locally in-memory on the node.<br>- `cluster`: Counters are stored in the Kong data store and shared across the nodes.<br>- `redis`: Counters are stored on a Redis server and shared across the nodes.<br><br>In DB-less and hybrid modes, the `cluster` config policy is not supported.<br>For DB-less mode, use one of `redis` or `local`; for hybrid mode, use `redis`, or `local` for data planes only.<br><br>In Konnect, the default policy is `redis`.<br><br>For details on which policy should be used, refer to the [implementation considerations](#implementation-considerations) | string | false | `local` |
| `config.fault_tolerant` | A boolean value that determines if the requests should be proxied even if Kong has troubles connecting a third-party data store. If `true`, requests will be proxied anyway, effectively disabling the rate-limiting function until the data store is working again. If `false`, then the clients will see `500` errors | boolean | true | `true` |
| `config.hide_client_headers` | Optionally hide informative response headers | boolean | true | `false` |
| `config.redis_host` | When using the `redis` policy, this property specifies the address to the Redis server | string | semi | |
| `config.redis_port` | When using the `redis` policy, this property specifies the port of the Redis server. By default is `6379` | integer | false | `6379` |
| `config.redis_username` | When using the `redis` policy, this property specifies the username to connect to the Redis server when ACL authentication is desired | string | false | |
| `config.redis_password` | When using the `redis` policy, this property specifies the password to connect to the Redis server | string  | false | |
| `config.redis_ssl` | When using the `redis` policy, this property specifies if SSL is used to connect to the Redis server | boolean | true | `false` |
| `config.redis_ssl_verify` | When using the `redis` policy with `redis_ssl` set to `true`, this property specifies it server SSL certificate is validated. Note that you need to configure the lua_ssl_trusted_certificate to specify the CA (or server) certificate used by your Redis server. You may also need to configure lua_ssl_verify_depth accordingly | boolean | true | `false` |
| `config.redis_server_name` | When using the `redis` policy with `redis_ssl` set to `true`, this property specifies the server name for the TLS extension Server Name Indication (SNI) | string | false | |
| `config.redis_timeout` | When using the `redis` policy, this property specifies the timeout in milliseconds of any command submitted to the Redis server | number | false | `2000` |
| `config.redis_database` | When using the `redis` policy, this property specifies the Redis database to use | integer | false | `0` |

> **Note**: At least one limit (`second`, `minute`, `hour`, `day`, `month`, `year`) must be configured. Multiple limits can be configured.

---

### JSON config format
```json
{
  "name": "rate-limiting-quotas",
  "enabled": true,
  "service": null,
  "route": {
    "id": "ffe7f02a-654b-411f-b625-351113ca2148"
  },
  "config": {
    "fault_tolerant": true,
    "quotas": {
      "minute": [ "plus:5", "enterprise:10" ],
      "hour": null,
      "day": null,
      "month": null,
      "year": null,
      "second": null
    },
    "minute": 3,
    "hour": 60,
    "day": null,
    "month": null,
    "year": null,
    "limit_by": "consumer"
  }
}
```

---

## How the limit is applied with quotas


| consumer   |       ACLs       | rate-limiting default | rate-limiting-quotas          | limit applied |
|------------|------------------|-----------------------|-------------------------------|---------------|
| consumer 1 | pro              | minute=5              | pro.minute=10                 | 10 per minute |
| consumer 2 | pro, enterprise  | minute=5              | pro.minute=10, enterprise=50  | 50 per minute |
| consumer 3 | pro              | minute=5              | enterprise.minute=50          |  5 per minute |

---

## Headers sent to the client

When this plugin is enabled, Kong sends additional headers
to show the allowed limits, number of available requests,
and the time remaining (in seconds) until the quota is reset. Here's an example header:

```
RateLimit-Limit: 6
RateLimit-Remaining: 4
RateLimit-Reset: 47
```

The plugin also sends headers to show the time limit and the minutes still available:

```
X-RateLimit-Limit-Minute: 10
X-RateLimit-Remaining-Minute: 9
```

If more than one time limit is set, the header contains all of these:

```
X-RateLimit-Limit-Second: 5
X-RateLimit-Remaining-Second: 4
X-RateLimit-Limit-Minute: 10
X-RateLimit-Remaining-Minute: 9
```

When a limit is reached, the plugin returns an `HTTP/1.1 429` status code, with the following JSON body:

```json
{ "message": "API rate limit exceeded" }
```


> **Warning**: The headers `RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset` are based on the Internet-Draft [RateLimit Header Fields for HTTP](https://tools.ietf.org/html/draft-polli-ratelimit-headers-01). These could change if the specification is updated.

## Implementation considerations

The plugin supports three policies.

| Policy    | Pros | Cons   |
| --------- | ---- | ------ |
| `local`   | Minimal performance impact. | Less accurate. Unless there's a consistent-hashing load balancer in front of Kong, it diverges when scaling the number of nodes.
| `cluster` | Accurate, no extra components to support. | Each request forces a read and a write on the data store. Therefore, relatively, the biggest performance impact. |
| `redis`   | Accurate, less performance impact than a `cluster` policy. | Needs a Redis installation. Bigger performance impact than a `local` policy. ||

Two common use cases are:

1. _Every transaction counts_. The highest level of accuracy is needed. An example is a transaction with financial
   consequences.
2. _Backend protection_. Accuracy is not as relevant. The requirement is
   only to protect backend services from overloading that's caused either by specific
   users or by attacks.

### Every transaction counts

In this scenario, because accuracy is important, the `local` policy is not an option. Consider the support effort you might need
for Redis, and then choose either `cluster` or `redis`.

You could start with the `cluster` policy, and move to `redis`
if performance reduces drastically.

Do remember that you cannot port the existing usage metrics from the data store to Redis.
This might not be a problem with short-lived metrics (for example, seconds or minutes)
but if you use metrics with a longer time frame (for example, months), plan
your switch carefully.

### Backend protection

If accuracy is of lesser importance, choose the `local` policy. You might need to experiment a little
before you get a setting that works for your scenario. As the cluster scales to more nodes, more user requests are handled.
When the cluster scales down, the probability of false negatives increases. So, adjust your limits when scaling.

For example, if a user can make 100 requests every second, and you have an
equally balanced 5-node Kong cluster, setting the `local` limit to something like 30 requests every second
should work. If you see too many false negatives, increase the limit.

To minimise inaccuracies, consider using a consistent-hashing load balancer in front of
Kong. The load balancer ensures that a user is always directed to the same Kong node, thus reducing
inaccuracies and preventing scaling problems.

### Fallback to IP

When the selected policy cannot be retrieved, the plugin falls back
to limiting usage by identifying the IP address. This can happen for several reasons, such as the
selected header was not sent by the client or the configured service was not found.

---

## Changelog

**1.0.0**

* Forked from original `rate-limiting` plugin
* Added configuration to quotas the limit from consumer ACL group
