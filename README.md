# Simple Backhaul_tunnel



Runs a tunnel from the first server (Iran) to the second server (Kharej), as simple tcp.

First, run this script on the Iran server and note the generated token.

Then, on the second server (Kharej), type the command and enter the token.


# One Click run
```
bash -c "$(curl -sSL https://raw.githubusercontent.com/Loperdax/backhaul_tunnel/refs/heads/main/install_backhaul.sh)"
```


Enter the ports separated by commas:   

  1515,2534        ->    tunnel port to same port
  
  1515:1616 , 3565:7574    -> tunnel port to diffrent port


Add an issue to add more protocols.
