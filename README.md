This is not a finished botnet to use, but maybe someday i will finish it. this is a simple tip for writing ur own botnet that will be better than mirai and qbot.

I decided to start this project cause script kiddies are selling shitty mirai srcs. 

btw: this project was written in two days from scratch, hahaha.

feel free to create issues and contribute

## Killer 
the killer principle is very simple. I wrote a very simple [killer](https://github.com/bstrdlord/mirai-sucks/blob/main/bot/Killer.zig) (kill by port, rebind ports), cause it's very boring to do, but you can easily add on to it.

[Mirai sources (u can find killers there)](https://github.com/R00tS3c/DDOS-RootSec/tree/master/Botnets/Mirai)

## Methods 

So far i've only written xmas and udp methods, but I've written a handy [api](https://github.com/bstrdlord/mirai-sucks/tree/main/bot/attack/headers) for writing methods

### xmas method (spoofed)
All flags are set and ip is spoofed. ([src](https://github.com/bstrdlord/mirai-sucks/blob/main/bot/attack/xmas.zig))
![image](https://github.com/user-attachments/assets/6a77f8be-322f-47f3-9a22-95242ec290d0)

### udp method (not spoofed)
[src](https://github.com/bstrdlord/mirai-sucks/blob/main/bot/attack/udp.zig)

![image](https://github.com/user-attachments/assets/332f2bd9-0311-42a7-8e93-91f64b4631ea)




## Caller 
Simple [caller](https://github.com/bstrdlord/mirai-sucks/blob/main/bot/attack/Caller.zig) that uses fork. You can rewrite it and use threads or uring

## Demo 
I didn't work on the design
![image](https://github.com/user-attachments/assets/59b73093-9ea5-4f16-8ef6-c2d1afd7ee2b)
![image](https://github.com/user-attachments/assets/73d9d9ea-9d89-44d1-b983-e099ef5ce93c)

![image](https://github.com/user-attachments/assets/841480c4-eec0-4f36-bfa4-a97e17615c7a)


## Script kiddies 
![image](https://github.com/user-attachments/assets/ee94caed-ca31-4cee-9855-1b6c2f07d9b6)
![image](https://github.com/user-attachments/assets/a6b861ec-b292-44ff-986a-eb1412b90496)
![image](https://github.com/user-attachments/assets/e89bff67-aecf-4399-b83e-f1c086ff95cd)

