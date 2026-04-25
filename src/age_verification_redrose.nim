import os
import posix
import strutils
import sequtils

when isMainModule:
  if getuid() != 0:
    echo "must run as root"
    quit(1)

  var etc_age: string
  try:
    etc_age = readFile("/etc/age")
    let etc_age_file = open("/etc/age", fmAppend)

    let lines = readFile("/etc/passwd").strip().splitLines()
    let users = lines.mapIt(it.split(':')[0])
    for user in users:
      if user == "root":
        continue
      var skip = false
      let grp = getgrnam("skip-age")
      if grp != nil:
        var i = 0
        while grp.gr_mem[i] != nil:
          if $grp.gr_mem[i] == user:
            skip = true
            break
          inc i
      if skip: continue
      if not (user & ":" in readFile("/etc/age")):
        echo "User " & user & " is not in /etc/age."
        echo "A - 0-13    B - 13-16   C - 16-18   D - 18+   E - add `skip-age` group"
        var input = ""
        while not (input.toLowerAscii in ["a", "b", "c", "d", "e"]):
          stdout.write user & ": "
          input = readLine(stdin)

        let bracket = if input.toLowerAscii().strip() == "a":
                        "0-13"
                      elif input.toLowerAscii().strip() == "b":
                        "13-16"
                      elif input.toLowerAscii().strip() == "c":
                        "16-18"
                      elif input.toLowerAscii().strip() == "d":
                        "18+"
                      else:
                        ""
        etc_age_file.write(user & ":" & bracket & "\n")

  except:
    let etc_age_file = open("/etc/age", fmAppend)
    echo "It looks like you are setting up age verification for the first time."
    echo "The installer of your distro should do this, so if you have installed it manually, pick the age bracket for all users:"
    echo "A - 0-13    B - 13-16   C - 16-18   D - 18+   E - add `skip-age` group\n"

    let lines = readFile("/etc/passwd").strip().splitLines()
    let users = lines.mapIt(it.split(':')[0])
    for user in users:
      if user == "root":
        continue
      var input = ""
      while not (input.toLowerAscii in ["a", "b", "c", "d", "e"]):
        stdout.write user & ": "
        input = readLine(stdin)

      if input.toLowerAscii().strip() == "e":
        if execShellCmd("groupadd -f skip-age") != 0:
          echo "failed to create skip-age group."
          quit(1)
        if execShellCmd("usermod -aG skip-age " & user) != 0:
          echo "failed to add skip-age group."
          quit(1)
        continue
      let bracket = if input.toLowerAscii().strip() == "a":
                      "0-13"
                    elif input.toLowerAscii().strip() == "b":
                      "13-16"
                    elif input.toLowerAscii().strip() == "c":
                      "16-18"
                    elif input.toLowerAscii().strip() == "d":
                      "18+"
                    else:
                      ""
      etc_age_file.write(user & ":" & bracket & "\n")
