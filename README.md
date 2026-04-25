## A concept of how age verification on Linux could work - `age-verification-redrose`

> ![IMPORTANT]
> This is just a concept and is not yet used in Redrose Linux, and we are not planning to use it just yet.

> our - refers to YOU, YOU as your distros maintainer as the reader

At first, we want to create a different _flavor_ of our distro for people from California, Colorado, etc.. This flavor would have
an installer that installs `age-verification-redrose` after creating the initial user, then write their age bracket into `/etc/age`.
Every time `age-verification-redrose` runs (for example as a startup service), it checks if every user has their age bracket in the
`/etc/age` file. For example, this could be a valid `/etc/age` file:

```
kid1:0-13
kid2:13-16
parent:18+
```

If a user is not in the file, the program asks for the age bracket of the user:

```
User mostypc123 is not in /etc/age.
A - 0-13    B - 13-16   C - 16-18   D - 18+   E - add `skip-age` group
mostypc123: 
```

An example runit service for the program is located in `./etc/service/age-verification-service`. Use it as you need.

Since a lot of users are created as `qemu` or `flatpak` and MANY MANY more, every user in the `skip-age` group is completely ignored.

The installer of our distro would set the age brackets for users it creates. If not, the user would manually enter the age brackets:

```
It looks like you are setting up age verification for the first time.
The installer of your distro should do this, so if you have installed it manually, pick the age bracket for all users:
A - 0-13    B - 13-16   C - 16-18   D - 18+   E - add `skip-age` group

bin: e
daemon: e
mail: e
...
```

If all checks pass, the config file exists, all users are in the config file, the program exits.

The problem is, what about `useradd`? The user could use the new user they created until they reboot! For this problem, we have created
a wrapper of `useradd` that runs the `age_verification_redrose` command every time a new user is created. It is located in `./src/useradd`.
