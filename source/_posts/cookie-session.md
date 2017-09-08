---
title: Cookie和Session原理
date: 2017-08-25 09:56:26
tags: [WEB]
---

Cookie和Session是为了在无状态的HTTP协议之上维护会话状态，使得服务器可以知道当前是和哪个客户在打交道。本文来详细讨论Cookie和Session的实现机制，以及其中涉及的安全问题。

<!-- more -->

因为HTTP协议是无状态的，即每次用户请求到达服务器时，HTTP服务器并不知道这个用户是谁、是否登录过等。现在的服务器之所以知道我们是否已经登录，是因为服务器在登录时设置了浏览器的Cookie。Session则是借由Cookie而实现的更高层的服务器与浏览器之间的会话。

## Cookie 的实现机制

Cookie是由客户端保存的小型文本文件，其内容为一系列的键值对。 Cookie是由HTTP服务器设置的，保存在浏览器中， 在用户访问其他页面时，会在HTTP请求中附上该服务器之前设置的Cookie。 那么Cookie是怎样工作的呢？下面给出整个Cookie的传递流程：

1. 浏览器向某个URL发起HTTP请求
2. 对应的服务器收到该HTTP请求，并计算应当返回给浏览器的HTTP响应。
3. 在响应头加入Set-Cookie字段，它的值是要设置的Cookie。
4. 浏览器收到来自服务器的HTTP响应。
5. 浏览器在响应头中发现Set-Cookie字段，就会将该字段的值保存在内存或者硬盘中。Set-Cookie字段的值可以是很多项Cookie，每一项都可以指定过期时间Expires。 默认的过期时间是用户关闭浏览器时。
6. 浏览器下次给该服务器发送HTTP请求时， 会将服务器设置的Cookie附加在HTTP请求的头字段Cookie中。浏览器可以存储多个域名下的Cookie，但只发送当前请求的域名曾经指定的Cookie， 这个域名也可以在Set-Cookie字段中指定）。
7. 服务器收到这个HTTP请求，发现请求头中有Cookie字段， 便知道之前就和这个用户打过交道了。

总之，服务器通过Set-Cookie响应头字段来指示浏览器保存Cookie， 浏览器通过Cookie请求头字段来告诉服务器之前的状态。 Cookie中包含若干个键值对，每个键值对可以设置过期时间。

## Cookie 的安全隐患和防篡改

发送HTTP请求的不只是浏览器，很多HTTP客户端软件（包括curl、Node.js）都可以发送任意的HTTP请求，可以设置任何头字段。 假如我们直接设置Cookie字段并发送HTTP请求， 就可以欺骗服务器岂，这种攻击非常容易，Cookie是可以被篡改的！

为加强安全，服务器可以单独为每个Cookie项生成签名，由于用户篡改Cookie后无法生成对应的签名， 服务器便可以得知用户对Cookie进行了篡改。

例如，`Set-Cookie: authed=false|6hTiBl7lVpd1P`为authed项为false时生成一个加密的签名，客户端可以随意篡改authed字段，但是无法生成authed为false时的签名，服务端校验失败。

但是因为Cookie是明文传输的， 只要服务器设置过一次authed=true|xxxx我不就知道true的签名是xxxx了么， 以后就可以用这个签名来欺骗服务器了。因此Cookie中最好不要放敏感数据。 一般来讲Cookie中只会放一个Session Id，而Session存储在服务器端。

## Session 的实现机制

Session 是存储在服务器端的，避免了在客户端Cookie中存储敏感数据。 Session 可以存储在HTTP服务器的内存中，也可以存在内存数据库（如redis）中， 对于重量级的应用甚至可以存储在数据库中。
1. 用户提交包含用户名和密码的表单，发送HTTP请求。
2. 服务器验证用户发来的用户名密码。如果正确则把当前用户名（通常是用户对象）存储到redis中，并生成它在redis中的ID。
3. 设置Cookie为sessionId=xxxxxx|checksum并发送HTTP响应， 仍然为每一项Cookie都设置签名。
4. 用户收到HTTP响应后，便看不到任何敏感数据了。在此后的请求中发送该Cookie给服务器。
5. 服务器收到此后的HTTP请求后，发现Cookie中有SessionID，进行放篡改验证。
6. 如果通过了验证，根据该ID从Redis中取出对应的用户对象， 查看该对象的状态并继续执行业务逻辑。
Web应用框架都会实现上述过程，在Web应用中可以直接获得当前用户。 相当于在HTTP协议之上，通过Cookie实现了持久的会话。这个会话便称为Session。

## flask中cookie和session的使用

```python

main.secret_key = 'A0Zr98j/3yX R~XHH!jmN]LWX/,?RT'

@main.route('/add')
def login():
    res = make_response(render_template("index.html"))
    res.set_cookie(key='username', value='letian')
    session['name'] = 'tom'
    return res

@main.route('/show')
def show():
    print request.cookies.get('username')
    if 'name' in session:
        print session['name']
    return request.cookies.get('username')
```
客户端add的时候，分别在cookie中设置username，在session中设置name，使用session需要设置secret_key；客户端的show请求中，我们就能看到cookie中同时包含username：letian和session字段，在session中能解析到name字段。
