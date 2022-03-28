get.bpkg.sh
===========

> An installer script living at the `https://get.bpkg.sh` for [bpkg](https://github.com/bpkg/bpkg)

## Usage

```sh
curl https://get.bpkg.sh | bash
```

### Development

#### Local Server

##### Prerequisites

Install [`serve`](https://github.com/vercel/serve) or [`budo`](https://github.com/mattdesl/budo)

##### Starting server

```sh
bpkg run server
```

You can optionally override the port the server listens on by setting
the `PORT` environment variable which defaults to `PORT=3000`.
