local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local memory = require 'memory'
local sampev = require 'lib.samp.events'
local ffi = require 'ffi'

local hasWebcore, webcore = pcall(require, 'webcore')
local browser3 = nil
local inventory_open = nil

local lvladmin = 12
local acladmin = 0
local fdadmin = "Нет"
local fd2admin = "Нет"
local rid = -1
local rep
local nickPlayer = "Nil"
local modelid = 1

local playerREP = 0


local serverIP = "46.174.54.87"
local modelAvatars = {
    [313] = "https://cs2.gtavicecity.ru/screenshots/9a0d4/2019-10/original/aeb1656e2b203b9e450c7f11c83d0646e54d9cfd/742589-gta-sa-2019-10-13-13-10-04-44-result.jpg",
    [314] = "https://cs2.gtavicecity.ru/screenshots/9a0d4/2019-10/original/1e047e673b61ca83416a86f962ba4cc3fc573672/742598-gta-sa-2019-10-13-13-17-13-71-result.jpg",
    [315] = "https://cs2.gtavicecity.ru/screenshots/9a0d4/2020-01/original/5cb1a273d38f3f5febd8a890b0817939c48837fc/774904-gta-sa-2020-01-30-16-17-52-26-result.jpg",
    [316] = "https://cs2.gtavicecity.ru/screenshots/9a0d4/2020-01/original/325ea4fed0a46e3ebf1842b1ce4c037b502ca442/774898-gta-sa-2020-01-30-16-19-13-64-result.jpg",
    [317] = "https://arz-wiki.com/wp-content/uploads/2022/11/1526-1.png",
    [318] = "https://cs4.gtavicecity.ru/screenshots/9a0d4/2022-04/original/407489983654eba5efebdeef19bb340eea622895/1047000-gallery2.jpg",
    [319] = "https://arz-wiki.com/wp-content/uploads/2022/11/1528-1.png",
    [329] = "https://arz-wiki.com/wp-content/uploads/2023/03/1529-1.png",
    [332] = "https://arz-wiki.com/wp-content/uploads/2022/11/1530-2.png",
    [382] = "https://arz-wiki.com/wp-content/uploads/2022/11/1532.png",
    [383] = "https://arz-wiki.com/wp-content/uploads/2022/11/1533-1.png",
    [398] = "https://arz-wiki.com/wp-content/uploads/2022/11/1534-1.png",
    [399] = "https://arz-wiki.com/wp-content/uploads/2022/11/1535.png",
    [795] = "https://arz-wiki.com/wp-content/uploads/2022/11/1536.png",
    [799] = "https://arz-wiki.com/wp-content/uploads/2024/08/7888.png",
    [908] = "https://arz-wiki.com/wp-content/uploads/2024/08/7892.png",
    [1206] = "https://arz-wiki.com/wp-content/uploads/2022/11/1612-1.png",
    [1326] = "https://arz-wiki.com/wp-content/uploads/2022/11/1613-1.png",
    [2883] = "https://arz-wiki.com/wp-content/uploads/2022/11/1616.png",
    [2884] = "https://arz-wiki.com/wp-content/uploads/2022/11/1617-2.png",
    [3136] = "https://arz-wiki.com/wp-content/uploads/2022/11/1618-1.png",
    [3138] = "https://arz-wiki.com/wp-content/uploads/2022/11/1620-2.png",
    [3140] = "https://arz-wiki.com/wp-content/uploads/2024/08/7889.png",
    [3141] = "https://arz-wiki.com/wp-content/uploads/2022/11/1623.png",
    [3142] = "https://arz-wiki.com/wp-content/uploads/2022/11/1624.png",
    [3145] = "https://arz-wiki.com/wp-content/uploads/2024/07/7773.png",
    [3146] = "https://arz-wiki.com/wp-content/uploads/2024/07/7764.png",
    [3147] = "https://arz-wiki.com/wp-content/uploads/2022/11/1629-1.png",
    [3150] = "https://arz-wiki.com/wp-content/uploads/2024/08/7878.png",
    [3151] = "https://arz-wiki.com/wp-content/uploads/2022/11/1633-1.png",
    [3153] = "https://arz-wiki.com/wp-content/uploads/2024/08/7880.png",
    [3188] = "https://arz-wiki.com/wp-content/uploads/2022/11/1712-1.png",
    [3189] = "https://arz-wiki.com/wp-content/uploads/2022/11/1713-1.png",
    [3190] = "https://arz-wiki.com/wp-content/uploads/2022/11/1714-1.png",
    [3191] = "https://arz-wiki.com/wp-content/uploads/2022/11/1715-1.png",
    [3192] = "https://arz-wiki.com/wp-content/uploads/2022/11/1716-1.png",
    [3225] = "https://arz-wiki.com/wp-content/uploads/2022/11/1815-1.png",
    [3231] = "https://arz-wiki.com/wp-content/uploads/2024/08/7886.png",
    [3416] = "https://arz-wiki.com/wp-content/uploads/2022/11/1941.png",
    [3429] = "https://arz-wiki.com/wp-content/uploads/2022/11/1942.png",
    [3610] = "https://arz-wiki.com/wp-content/uploads/2022/11/1943.png",
    [3784] = "https://arz-wiki.com/wp-content/uploads/2022/11/1945-1.png",
    [3883] = "https://cs4.gtavicecity.ru/screenshots/9a0d4/2014-06/original/c488c2e096517468825600a2b54febb8dc1c0e47/190332--3.JPG",
    [4766] = "https://arz-wiki.com/wp-content/uploads/2022/11/2015.png",
    [4767] = "https://arz-wiki.com/wp-content/uploads/2022/11/2016-1.png",
    [4770] = "https://arz-wiki.com/wp-content/uploads/2024/08/7877.png",
    [5378] = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxMTEhUSExMVFRUXFxcYFxgXFRcYFRgXGBgXFxcYFxcaHSggGBolHhUXITEhJSkrLi4uFx8zODMtNygtLisBCgoKDg0OGxAQGi0lICUtLS0tLS0tLS0tLy0tLS0tLS0tLS0tLS0tLS0tLS0tKy0tLS0tLS0tLS0tLS0tLS0tLf/AABEIAKgBLAMBIgACEQEDEQH/xAAcAAABBQEBAQAAAAAAAAAAAAAAAQIDBAUGBwj/xABGEAABAwIDBQUECAMHAQkAAAABAAIRAyEEEjEFQVFhcRMigZGhBjKx8AcUQlJiwdHhFXKiIyQzgpKy8XMWNENEg5OjwsP/xAAZAQEBAQEBAQAAAAAAAAAAAAAAAQIDBAX/xAApEQACAgICAQMCBwEAAAAAAAAAAQIRAxIhMQQTQVEyYQUikaGxwfBx/9oADAMBAAIRAxEAPwDp9m7Qa5pBd3dND5iBzWh2bXXt0NvHxVLD4VjWiCCRqBu5WV3D1w2y5xr3ObEoUy2W9YiOqWk0O+zGs8I3K03CiZN+CirggkDTgp6dXJjb2Mb2QLcpEOBtYxG/SHH4ro8oXL+y5ytJAiT95zgTeYBADfBdJRr5rQtYpxXBrKntZJlCMoTkLucSOoQASdypDFuNwwAc7nl5rRUdV0CwlR2CBtfc4AdFUxtYteMp1BMRNpCkqtq/dBHDMB67ismjSc4Nq9o5gdMNibEyBLp5Xgblhtvg0adMEjM52Unnp+SvYcW1zcyBKxcLhjnMZibd4uESbx3dBfgtdhqDUAjfe8clYugyyGTuQW8lE3EQ6VLUxIdoJPAK7mvTdCZQiAhz3ASWQOYTxiDbugzyTcemytXqhsW1+KztuuIa17QIMgnrotqo1p96nHmFn1tmBzhL5YN2/pwXnzbTi412FBo5PE0HFhqkGJg28dd3BbexmU3McwgANA4axcjeDK6HDubBpwMsRG6NIWBhcE6k97A7LDt7QQ5urT6lcMWL0pc832akjLx2x31ia1NwaWGAd7suh5/uVZ2WTmLXBzajTJEAzLSPFtzHRS4mpVyuY1wAE5iBcdLHikds17mtqNIDqcgEGTG8OkA89V0hGF/l7RF9yTYj5pkhs5HunhuJ18VbrMPeGUAv1OpjcIsquwHkUqn3u0NhpOVvJXtntmC65IJN5AvAC6YuYRX2Lk+plNmHu1pAa1skAECSTr1UYoS86iOIuVf2biIBBj3iBHUz1UuLe2S0EZgJg8Ou5cp4ozjad18mdhtLDAjUdI0VylTgRqq+DAjMfVWwV6MMFFWlRhsTKEZQnIXYg2AjKE5CAblCy9kDv1j+L83LWWTsLWofxfqp7lXRqZQjKE5CpDnsA0yCJaSATrG6xV90OdBBa47xFz4aqduGyuBFwR68OX7KGs6xuWxuOvIheVrSJ1XLGOquBiSIPVaGHqZhO9ZzsZLcrtTEHprJUtPEtaBlmJvv8Fcc+exKJi+zdHM6oBlBBdMGRZxGm5btGg9pmJWH7N4sdvVbLT3njeHAZ5EguNughdXC1CEXyXI3YkIhOhELuchsIIToRCAzMSKjgcriInTTj4rgPaDaVSh9Wyy4upixMgAtIFt05V6lC43bOwWYijhHOcWEFjDAFw60X3iPUrlkhaNwavkl9ntmvFNtUPcXOAdqYLXXAgmO7m9F0tQkMvrF+u9S06YaA0WAAA6CwUOO0C1WqJHllQlVtpUMQaTzhq3Z1cpyS1hbm3Zi5rrdAp2AkwBKu0MHUjSOpWDsUsGzFNY3Pii5+UZ81Ok6nmjvQGsY4tmYuCpcTTr5gGVWMAaLGk5xJ3me0AA5QdNVp0tn73GeQ0UmKwma4MFKFnNbMxO0jXrMqOw4otLeye6kXGqCO9ZtYZINrgytR+YGCADwa4uHgSAfRS/V3jUeRCsNo3koOCkw5TdVdtF3dqNGYCzx+HjG+JKu4+zx0/NUtoYrJTJibgRxk6LE61dh9FDFEzIygPaRAuZ3E39Fq4amC1pktdAnfcWv+iyyym8gtkfakyD6Kei4sMtcNTM2DrzeNDvmFjFqm5fJzplLZL3N7QhkgPhxEk9MoufDyVnaO0AcgaTJMQAQfWDGvkmezOIaG1S5wvUsJE+6PzJWi+tSzS5wBaDFwTB10laxxvElZrJ9bMbA4Fr6kgvaGzaQYdMAjfuOvBP2hRFNwu4udMudcWET8VoNx9Ck05bG5gNMnddZT9pGo0hzRJ4wABrrM+i4TWOENW+e/wDfwY5sRmIzNa3M47rnUzFhounwzCGgON+Wi57Z+FOYOa1pjlI6raYau/KOUrfjT7bt39uCNFyEQhgO9Ohe4yNhEJ0JgdeEApWT7Pe64/i/JatazSeR+CzPZwf2bv5vyCnuX2NSEQnQiFSFKs5zmSC3QGBf1UD8OXNkucTwdcW4cFco0ImCR+igxZMENvbeD/wvPkTaOkHyUDhyO9IN45zvsgN+YUowz4BjQX8lA+hIbEm9xx6FcNeODdmPs2rFSoJP+I+AQI943nLceK26WJe10NII62noVibPaRXqAj7brmIFpgkCR4la7KgH3depgLDm0+Dc0mW2bVIOVwBO/dHEdVLh9oEvg2BsOPJUa3JhBuQSN5VzCYB4IJy8Y1uuuPJkbo5OMUaiEIXsOQLn6jv7vhv+tT/3kLoVzeJd/dqJ4V2+lVykujUezo1BigCIKXEV4sNfgqzVJM1CPuXaD4EaBT/Wgua2v7S4TDSK+IpscBOUul8bu42Xei5bG/S3gmGKbK1XmGhrfDMQT5LFHWz1FmIBUocFwGx/pG2dXgdv2Tvu1h2cf5vc/qXX4euHAOa4OB0LSCD0ITklJmkonplKupXXVTI1Rj7WeAWkmNQsTbT8zMgN5ny09YW1tvDFzWxudJvAiD+y5s0SXQBJFxqeUrzeQ5cxJZZwlStTjutjXnzab/Mq/XxbWg90lzmm1jfTp/wq7cYzQh1/vExO+J10SYy1N5EucJMzfKeQ0Nx5JzGP5XZKtkexS6lTIBBJdm00MARH+WfFPxOKzCHFxNzbutI5E74sqmy2F1I1MuZpzGLn3YBk7yYPKyn2g8xkJAt3dLaSAfy6LljlOMKZZfUV6FRjtSG9L23XG/cqzsPlOaBJsNNON1cGEaILe8SLAC5jeTwCjbg2td3wJPOLrllxyaukCzhKbxrAHACP2K1dm0+nlCyaNRrXN3Qd4XTU4iREHgvV4uNqnZiTFSoQvaYKuMrZIdumCOPzdVsbWLXBwNt45az8VLtUjLGp+CyWyW9Nb+Sy2aSNOvtBpY+94dp0sqOx8XlpwBfMfgFRruPe6FLs89zxKy5M0oms7EumZKPrz/kKmHoz8vVZ2NUvg3gwmCbW3FNfGgusjAbcFRhc0ggWHP5t5rSpVA5gMG4m6spJ9GIonwzRlB4gfBPdTsYgH8+KrbNrA02/yj4K6tQquCSuziqWHf8AXKjTJ7wuH2ktBuwvj0/VbuFwkOAc2wM8Y8VhbRxLqeLrvADshaebYY08L9JVV3t84mKYpOO/3reRXJRjfJ1ldL/h3jqYMSNE6Fwv/bp7Y7RtIA7+9A4b102B2m59Z1ItEBuaZvqBEeK6+pG6+Tno6s1IRCVC2YI2EmDAg8/2XM47/ujOWI//AGeumw3ut6D4Ll8cycK1vHFOb/8AK9Zl0bh2bD3S5x5/Bcj7f+2jcCzs2Q7EPHdbqGD77/yG/ouqYvnz6Qcb220cS4GQ1/Zj/wBMBhjxaT4rB1MPFYh9R7qlRxc9xJc4mSSd5USELRAXUewntlU2fV3voPI7Sn6Z2cHgeBAg7iOXQgPqnZ20Kdem2tSeH03iWuG8fkRoQbghaWGrbl4z9B20r4jDE/dqtH9D/jTXrlF11lmiXav+G48AT5XXOMxQyWN90DeOO8Lp3GQsPEUWkWpmeYsRyIXHLFvlGGhMK7tqUWBvLd/H4/FZm1KRZRiY3eZ3W3bxu6FWGvNNwc29rtgix/EBqodu7RD6XuwZEzHTUG46rnKlj57qjeOL2RLsjMKFMBzYOYjxcZB0jVR7erF2RuZogRa15jnG9aWyse1uHpNuSGNTMTWa4zlMnWYhdfTThV9mJO5GfggxoaHPzOAgnNeBuHAKXaFdkTO7QXPhCVwG63wTXMB1uqo6xpEKdakXnMzuiPtCBpe6sDGVyyC6RaABcjS0C6e4AiCJ6qzhcY5mlxwOn7Ln6KvuvkjNHZdCo1kvcZ4Tp4wp61fgY+KzsZtWQIsDungqpxPzK7RyRrWL6GvyaDzOp9FUsAQOKh+scik7fkU2NKhmN9wlMwLYYPFJjXnszaBb4pMH7gWWzSJ5TuzPFRiUl+KnHuU80wterR9x8DhAP5LUpe2GLaIAY6NJJ04Qsl/io5XnUqMHQ7M9t8Q3uvYMoFgI1HMnquwre1wFAmk3PVAFoho4ydCQNy8uhOBI0J8CtwyOLsj5R0VHHms6o6o8BzzcFoJgtsBDLCI3lYLqgEEMa2dSE3D1nMMtJHW48nSFHXdmDe6BlBEtkTMe8Jg6cOK0p8nSUk0kWsXWzANPeF4B0/Zeg7E2sx2JY4mM2Hk/zSARbm0rzjCVGB0vDj0hbP8AE6UtLXQQCLgixJMevqnqLZNmG3q0j1b+JUvvhH8SpffC8qdtI7nT0uFvbFp5g2o8kgjSSN69ayRZy1n8HZYXaVLI3vjRcntjGt+qkNd3hinkdMzyD8EtWg2oxpZ3SJEzIsSFytZ0iA7Me2Iy3nQwfFZnKOpuClvyj0nC1Q5ocDIIB8184+0mDdRxdem+S5tV9zq4Ekh3iCD4r3vYAcym1r5BIkWMCQJE6FedfTFsJ4qtxjGyxzWsqOA917bNLuRECfw8womdOTzdCELRAQhCA7D6JnP/AIlTyaFlTtP5MhP+4MXvjSvKfoP2X/j4ojhSYf63x/QvWAssqJBWDbuMAaqpUfhySc2vMx5Kt7QvIwldzQXODQQBqYIMBeYna+J3Ydw6lLhX5jlkcr4R6pXqULZS0enqsHbzaZaA0gySLEHW5/VcDidsYqCOy15mVQo7UxLTmyE9f3XLM4yg1E1ilJSWx6/gabG0KUmJa0DwbqfIorw03IEiRcaLyDEbZxdTKC4tDD3RaOQNu8NLH81V2htjF1Y7R7nZbDugQOFgFI5K7LLs9jdUbpI8woy9vEcdy8TFaud7/VS9jWP2z4krXqRM8ntGZushGdvFvO68VOHrHV/9RVdzCPt/FT1EU9fDS6qGgy1uaSTxgiD6eC0pbxEDmvETi6mXJ2jsvCTEqLK4/aPmViOsbo03Z7i+vTbq5o/zBLUxDG6uA/zBeFml19U5tIytbolntO0agyWO8b/FRDGMYxuZ0a6mPivPvZkv7Qy4kZdJtqP3VLa+He+tUPeIzGL2UclRbPRTt/DzHajzUh2vQ31G/wCsLyg7Od90pf4c77hWdkNjoXdEwhXjhubQgYIcVzUGNWULfIQtEYNo4+acKA+6FpQZdTM1TxRPBaRppuVa0Q1KH1bmEv1VXcqjqvDdXR5K6ouqK4ww4KxTe9ohr3gcnED4qk/HEnKwFx6fkmVmPNqj4/C2CfE+6PXoraRaJ6uNy2L3HkHE68lWD3D8F5vd88Q3cesJA4N9wZeervF2vlAUcK8lNGltqs0ZW1HxOpdmPhOg5Bdh7O+0DMQ36viA0ucMveAyVAbEEaZuW/0XBMYpmhaXBBPa36Mq9OoX4Nhq0TcMzDtKf4bnvt4EX3HSTwmMwdSk7LVpvpu4PaWnyIXpuG9tcZSdGZlVoMRUbeBaA9sHxOZdBhvbvD1m9ni8NAOohtan4hwB9Cumx6X4GdK9Tw+hRc85WNc5x3NBcfILuPYn6Oa+JfnxLH0aDdQ5pbUqfhaDdreLvLl6kz2s2dSYOzqNAizadJw9A0R4rPxP0jUB7lKq/rlaD6k+iWZj4WeXUH+lfydXhMIykxtOm0MY0Q1rRAAVfG7Rp0xL3sY0auc4NaPE2Xne3PbXEYhuSn/d2z3ix0vcOGeBlHS/NcyKILs7pc77zyXO/wBTpKh7Mf4Tml9TS/f/AH6npO2PbXDdlUpUc9dz2uaCwRTBIIBNR0AgH7uY8lw4r1tXOF9A2THVx97yCgwAdWfkoMdWfwpiQP5n+6wfzEK7idnV6T3MrNa0iIa0l2omS6wOu4btUa4Ln8fxcGNpSuf++P7KjsU/imfW3fJUj6RUTmLFHzBwxnEHyT212nh89VXLUkKUQvNDTwTxQCz8qe1x4lTUcF36qEjsGDuVdtd3VStxh3hTX7CkBwXL0TH4AHVWG4tu8eilbXYeHz1U1Q1RmO2Y3h6pBs1vA/PitpuU6fqkdRB3qaImhQwLBTJIEyI4KOtT7xM6knzWgMMeR8U44Z3BXVVQ1M5tNSZSr4ockdlyCxoyakl/koUV+Pw/RMc4gXfHWP0XU2WITYVCpjAPtuceQAHmR+Sq19quNhbpqep/RAa73AXcQFTr7RYNL+gVSns6q4ZnxTbxfY+A1JUzaNFmgNV3F9m+Dd/is7L2FETa9WrZjTG8iwHVxSDCMF6j85+6w93xf+ikr4lzrONtzRZo8BZQFytN9gldXMZWgMbwbaep1PioCUqAFpJIg0BSNYnNapWhWgIxi29ibAfX70wwGCdSTvAHjvWfhMO57g1rcxOgG/evQ8HR+q4dgMOeSRlBjM90ugcgAZPBpKWu2Dz/ANqPZR+EYazKnaMloyVGkVSXuygMLBDySdMo33VZ/svjx/5Qn+WtRPxeCu821srtmdq6q7tqU1KJkijTqNEt/s9HAcXS7vGCLAbOzMT2tKnVy5c7GPynVuZodB6TCxhzwzXp7HuXm+TiSW39nk/8Axot9TreBpEeYerWH9jse/8A8BlP/qVm/CmHL1xjU4rsWX4p5L9/2R5thPo5xLo7TEUmDeKdNzz4OcQP6V0ezPo7wjIL2uru41nZm/8AtiGf0rphWU1PFKnlyeTlycTk2S4TZ7WANa1rWjQNAAHQCyr7d2BTxLId3Xj3XgXHI8W8lZbilZo1ZS/k4UeL7W2c6jUdTeIc0wY04gg8CIKyqjF6F9ImEioyqPtNynq3T0P9K4SsxZNIouamqVzUwhQDYQlhKoBoSpUkKgEoCRLCAWE9tVw3nzUcJZUBYp4xw5+nwhWGbR4j1t8PzVCUSpqi2a9PaA4+Y/SVYZjGcR5gfFc/CVNRYV9oHkPiq1GnUqGGNLj86lbDcBh6Zl7jVdwbZvi79E6ttBxGVsMbwbbzOq57N9ItFGnslrb16kH7jRLvE6BWG4hrP8FgZ+I95/mdFXJCjc9XS+yWPqVSTJJJ4kyVG5yanALpRBqSEpTg1KA1PAQhUDgpGKFTUkYO49jNjOjtiAJEMk7vtO5cPNbXtGw02NcRORweSDPdEtedNzXOMckz2YxTThqZG5sHqLH1B81ffULyDuGiSipRcX7hOnZylbHtxI7DCvFQ1O6+pTOZlKmffc54loflkNbqSRaJK67D0Q0BoEAAAdBYKSmwDQATcwN/HqnhcvH8eOGNRNTm5u2K1NenhR1F6DBBUcn0sK8lpIIaTryUJfDgtLtSN9kBYGz27nO8x+iVtEsvMjpdOotdAIMTu1U4lDNnPe2OF7XDOO9hDx4WPoSfBeWYgL2zEURBG4ggjkdQvItrYM0qj6Z+ySPDcfEQUZpGK8KAtVqs1QSslIpQE9NCgEKEsoKAEqSEBAKiUJUAiIQhAEJLpZSSgJS+Exzk1ySFAEpCnQkhACQBOATgFQIAlhKU0lAKUkpCbcU1pQDgpGlNATwgN32d2yaDi10mmdQLkHiPgfDgu9wFYPY1wBhzQ4TrBEifNeVU16fsZ80aR/Az/aFURmqEqRKFoDk1wTk1AVa1NPoVYsfBSuCifTQF+hiXC2vTVXRW/CR4LJwFbK6/gtinVBUIxdQuC9v8BBbWA17juou0+IkeAXel4XFfSJih2dNn3nk/6RH/ANlW+CJcnn1YKm9qtVXhVXuCybI0Ickm36qACEqVKGoBqVIR8/8ACW6AbCVBSoBJQEIhAKUSEgQgEhIUJQEAkylaE8BOyIBoSJ7mpqoGngkcUseKT58kAwaqSEgHHonQoACc1NCe1UEjbr0P2UqTh6fLMPJxj0hedAQu49iah7N7TufP+oC3oi7B1wKcE1qcFog5IUqEA1EISoCF7U6nVI1TyEkICWpXAaSTAAkk6ADUleX+0e1ziKubRjZDOMcep18Aux9sq2XCPH3i1vrmPo0rzd3QX6LLZSN7lFKVxSKACkQR8/PRF0Aqc0JkIIQEohJAUeZAKAeQEwpf2SIAQQkEqzhqAfTe8ujKQBMd47wOmn6qgrBKFdoYIF4aXRIMbhyv4z0B0VN1ODGhGoIEg7wUANZ87k4U+vohCgHdnu+eSXJxQhAIWfMJC2+h/L4IQgG5EBqEIBxZy8EhZb5+f+EIQBB+R88UBunVCEBZZTN7aa/BeibCwXZUmtPvEZnfzH9LDwQhWIZtUzZPQhaIOCRKhANSpUIBhKaShCA4z25xmZ7aQ0aJP8ztJ8AP9S5FwJN0IXP3KRGnyTS1CFQAEp2XQ/khCATL+/z0SFpn1QhAKWlIG/P5oQhADU8sQhCiZFdGFoCP7V+4kNaC0E3PkRpxkoQlkHClQh39tUuLS2Ige6CDIBsOnBVNoU25u48uEC51J589LoQqWj//2Q==",
    [5389] = "https://arz-wiki.com/wp-content/uploads/2024/01/7267-1.png",
    [5685] = "https://arz-wiki.com/wp-content/uploads/2024/01/7270-1.png",
    [5688] = "https://arz-wiki.com/wp-content/uploads/2024/01/7273-1.png",
    [5690] = "https://arz-wiki.com/wp-content/uploads/2024/01/7275-1.png",
    [6021] = "https://arz-wiki.com/wp-content/uploads/2022/11/2256-1.png",
    [6545] = "https://arz-wiki.com/wp-content/uploads/2024/01/7307-1.png",
    [6549] = "https://arz-wiki.com/wp-content/uploads/2024/01/7311-1.png",
    [6550] = "https://arz-wiki.com/wp-content/uploads/2024/01/7312-1.png",
    [6586] = "https://cs4.gtaall.com/screenshots/4dc09/2023-05/original/39d4285516796c92f1e88df9aae1d51f9574687a/1247004-gallery1.jpg",
    [6587] = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9Y0TbR6fLWLm_zIDOJaYz-jwUSsQe7yqqDNYCLZFP2Jb7BGj-3ljBLbYl8LGQeuR1_Ow&usqp=CAU",
    [6594] = "https://arz-wiki.com/wp-content/uploads/2023/04/6385-1.png",
    [6596] = "https://arz-wiki.com/wp-content/uploads/2024/03/7428.png",
    [6672] = "https://arz-wiki.com/wp-content/uploads/2023/08/6801.png",
    [12654] = "https://arz-wiki.com/wp-content/uploads/2024/01/7022-1.png",
    [12655] = "https://arz-wiki.com/wp-content/uploads/2024/01/7023-1.png",
    [12658] = "https://arz-wiki.com/wp-content/uploads/2024/01/7025-1.png",
    [14358] = "https://arz-wiki.com/wp-content/uploads/2023/08/6971.png",
    [15097] = "https://arz-wiki.com/wp-content/uploads/2024/07/7774.png",
    [15448] = "https://arz-wiki.com/wp-content/uploads/2023/04/6389-1.png",
    [15570] = "https://arz-wiki.com/wp-content/uploads/2024/01/7091.png",
    [15985] = "https://arz-wiki.com/wp-content/uploads/2022/11/5722-2.png",
    [15987] = "https://arz-wiki.com/wp-content/uploads/2022/11/5724-1.png",
    [15988] = "https://arz-wiki.com/wp-content/uploads/2022/11/5725.png",
    [15989] = "https://arz-wiki.com/wp-content/uploads/2022/11/5726.png",
    [16834] = "https://arz-wiki.com/wp-content/uploads/2023/01/5946-1.png",
    [16835] = "https://arz-wiki.com/wp-content/uploads/2023/01/5947-1.png",
    [16838] = "https://arz-wiki.com/wp-content/uploads/2023/01/5950-1.png",
    [18168] = "https://arz-wiki.com/wp-content/uploads/2023/02/6217-1.png",

}

function checkadminka(nick)
    sampSendChat("/adminka " .. nick)
end

function formatREP(repString)
    -- Убираем 'Р' и ведущие нули
    local number = repString:gsub("P0*", "")
    -- Если строка пустая (были только нули), возвращаем "0"
    if number == "" then return "0" end
    return number
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if dialogId == 10003 then
        inventory_open = not inventory_open
        browser3:set_active(inventory_open)
        browser3:set_input(inventory_open)
        browser3:execute_js("document.querySelector('.inventory-title').textContent = 'Инвентарь';")
        browser3:execute_js("document.querySelector('.player-container').style.visibility = 'visible'")
        local reput = formatREP(rep)
        local avatarUrl = modelAvatars[modelid]
        if modelid >= 0 and modelid <= 311 then
            browser3:execute_js(string.format("updatePlayerAvatar('%s')", "https://adv-rp.com/media/roulette-prizes/skin-" .. tostring(modelid) .. ".png"))
            browser3:execute_js(string.format("updatePlayerName('%s')", nickPlayer))
        elseif avatarUrl then
            browser3:execute_js(string.format("updatePlayerAvatar('%s')", avatarUrl))
            browser3:execute_js(string.format("updatePlayerName('%s')", nickPlayer))
        end
        browser3:execute_js(string.format("updateProgress('%s', '%s')", reput.." REP " .. getPlayerMoney(ped) .. "$", ""))
        -- Очищаем инвентарь перед добавлением новых предметов
        browser3:execute_js("clearInventory();")
        
        local items = {}
        
        for line in text:gmatch("[^\r\n]+") do
            local id, name, count = line:match("%[(%d+)%]%s*(.+)%s*%((%d+).+%)")
            
            if id and name and count then
                table.insert(items, {
                    id = tonumber(id),
                    name = u8:encode(name:match("^%s*(.-)%s*$")),
                    count = tonumber(count)
                })
            end
        end
        
        for i, item in ipairs(items) do
            -- Добавляем предмет в интерфейс
            browser3:execute_js(string.format("addItem('%s', %d, %d)", 
                item.name:gsub("'", "\\'"):gsub("%{......%}", ""),
                item.count,
                item.id
            ))
        end
        return false;
    end

    if dialogId == 0 and style == 5 and title:find(u8:decode("(%w+_%w+)%s*%(%d+%/%d+%)")) then
        local nick = title:match(u8:decode("(%w+_%w+)"))
        inventory_open = not inventory_open
        browser3:set_active(inventory_open)
        browser3:set_input(inventory_open)
        browser3:execute_js("document.querySelector('.inventory-title').textContent = 'Инвентарь "..nick.."';")
        browser3:execute_js("document.querySelector('.player-container').style.visibility = 'hidden'")
        browser3:execute_js("clearInventory();")
        local items = {}
        
        for line in text:gmatch("[^\r\n]+") do
            local id, name, count = line:match("%[(%d+)%]%s*(.+)%s*%((%d+).+%)")
            
            if id and name and count then
                table.insert(items, {
                    id = tonumber(id),
                    name = u8:encode(name:match("^%s*(.-)%s*$")),
                    count = tonumber(count)
                })
            end
        end
        
        for i, item in ipairs(items) do
            -- Добавляем предмет в интерфейс
            browser3:execute_js(string.format("addItem('%s', %d, %d)", 
                item.name:gsub("'", "\\'"):gsub("%{......%}", ""),
                item.count,
                item.id
            ))
        end
        return false;
    end
    
    if dialogId == 10009 or dialogId == 10004 or title:find(u8:decode("Информация о предмете")) then
        -- Сохраняем данные диалога для контекстного меню

        local jsTitle = title:gsub("'", "\\'"):gsub("%{......%}", "")
        local jsButton1 = button1:gsub("'", "\\'"):gsub("%{......%}", "")
        local jsButton2 = button2:gsub("'", "\\'"):gsub("%{......%}", "")
        local jsText = text:gsub("'", "\\'"):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("%{......%}", "")
        print(jsTitle, jsButton1, jsButton2, jsText)
    
        -- Передаём данные в браузер
        browser3:execute_js(string.format(
            "setContextMenuData('%s','%s','%s','%s')",
            u8:encode(jsTitle), u8:encode(jsText), u8:encode(jsButton1), u8:encode(jsButton2)
        ))
        return false;
    end
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end

    if not hasWebcore then
        return
    end

    -- Ожидание инициализации WebCore
    while not webcore.inited() do wait(100) end

-- Создание браузера
    browser3 = webcore:create_fullscreen("file:///moonloader/cef/inventory/index.html")
    browser3:set_active(false)

    browser3:set_create_cb(function(_)
        browser3:add_function("sendDialog", function(_, name, args)
            sampSendDialogResponse(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), "")
        end)

        browser3:add_function("sendChat", function(_, name, args)
            sampProcessChatInput(u8:decode(args[1]))
        end)

        browser3:add_function("sendDialog2", function(_, name, args)
            sampCloseCurrentDialogWithButton(tonumber(args[1]))
        end)

        local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
        nickPlayer = sampGetPlayerNickname(id)
    end)

    browser3:set_loading_cb(function(_, status)
    end)

    while true do
    
        if isKeyJustPressed(0x49) and not sampIsDialogActive() and not sampIsChatInputActive() then
            sampSendChat('/i')
        end
        if isKeyJustPressed(0x1B) then
            inventory_open = false
            browser3:set_active(false)
            browser3:set_input(false)
        end
        wait(0)
        if isPlayerPlaying(ped) then
            rep = sampTextdrawGetString(2149)
            modelid = getCharModel(PLAYER_PED)
        end
    end
end

function sampev.onServerMessage(color, text)
    local lvl = text:match(u8:decode("Уровень админки (%d+)"))
    if lvl then
        lvladmin = lvl
    end

    local acl = text:match(u8:decode("Уровень Acl (%d+)"))
    if acl then
        acladmin = acl
        fdadmin = "Да"
        fd2admin = "Да"
    end

end

function onScriptTerminate(s, q)
    if s == thisScript() then
        webcore:close(browser3) -- close without callback
        browser3 = nil
    end
end