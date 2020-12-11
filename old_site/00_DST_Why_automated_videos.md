# Why Automated Videos

What's the deal with these videos? And why do the videos say almost exactly the same thing as the printed lecture material? You have probably already noticed that the lectures and videos for this class are structured a little differently than in many MOOCs you have taken. We created this video to explain to you why we made this change and why we think it highlights the awesome power of R and data science. 

We create a lot of massive online open courses at the Johns Hopkins Data Science Lab. We have created more than 30 courses on multiple platforms over the last 5 years. Our goal with these classes is to provide the best and most up to date information to the broadest audience possible. 

But there are significant challenges to maintaining this much material online. R packages go out of date, new workflows are invented, and typos - oh the typos! 

We used to make these courses like many other universities. We'd create course material in the form of lecture slides, then we'd record videos of ourselves delivering those lectures. In some ways this was great - you actually got to hear our voices delivering your lectures, including all the "yawns", "ums", "buts", and "so's". But the downside is that it is difficult and time consuming to update the content when we have to book a recording studio, set up special equipment, record ourselves delivering a lecture, edit those lectures, and then upload them to a system. 

The result is that a lot of our lectures have been out of date, include errors, or don't include the latest, best versions of wokflows and pipelines. This has been a problem for a while, but as the number of courses we offer grows, it has become more and more of a challenge for us to keep them up to date. 

So we started to think about how to solve this challenging problem. We realized that while recording and editing videos is extremely time consuming there is another type of content we can edit, update, and maintain much more frequently - [regular old plain text documents](https://simplystatistics.org/2017/06/13/the-future-of-education-is-plain-text/). We aren't the only ones who have thought this - massive online open course innovators like Lorena Barba have been saying that [videos aren't even necessary for these types of courses](https://www.class-central.com/report/why-my-mooc-is-not-built-on-video/). 


So when we sat down to develop our new process for creating and maintaining our courses we wanted to see if we could figure out how to make a class made entirely out of plain text documents. We broke down a massive online open course into its basic elements:

* __Tutorials__ - these we can easily write in plain text formats like markdown or R markdown. 
* __Slides__ - these are easy enough to maintain and share if we make them with something like [Google Slides](https://www.google.com/slides/about/).
* __Assessments__ - here we can use a [markup language](https://leanpub.com/markua/read#leanpub-auto-quizzes-and-exercises) to create quizzes and other assessments. 
* __Videos__ - this was the sticking point, how were we going to make videos from plain text documents? 

By a happy coincidence, the data science and artificial intelligence communities were solving a huge part of this problem for us, improving text to voice synthesis! So we could now write a script for a video and use [Amazon Polly](https://aws.amazon.com/polly/) to synthesize our voices! 


To take advantage of this new technology we created two new R packages: [ari](https://cran.r-project.org/web/packages/ari/index.html) and [didactr](https://github.com/muschellij2/didactr).


Ari will take a script and a set of Google Slides and narrate the script over the slides using Amazon Polly. It will also generate the closed caption file needed to include captions and ensure that the videos are accessible to those with hearing impairment. didactr automates several of the steps from creating the videos with ari, to uploading them to Youtube, so that we can quickly make edits to the scripts or slides, remake the videos, re-upload them and reduce our maintainence overhead for keeping our content fresh.  

Whenever we change the text file or edit the slides we can recreated the video in a couple of minutes. Everything is done in R. One of the coolest features of going to this new process is showing you how powerful the R programming langauge is. This is the main language you will learn in this program and we hope you will be able to build cool things like this system by the time you are done with our courses. 

Why did we choose this approach instead of creating each piece of a lesson separately? Well, first, this process makes it a lot easier for us to maintain and update the courses. If you report an issue or find a mistake with a lesson, all we need to do is to change these two files and recreate the courses again. Therefore, we will have a more efficient way of maintaining the course content and updating it. Second, by using this process we have made our instruction more accessible. Since videos have transcripts and transcripts have voice over, the content is accessible by those of us who have disabilities. For everyone else, you can have a choice of reading versus listening versus watching the content as you wish.

Finally, a cool feature of using text to speech synthesis is that our videos will keep getting better as the voice synthesis software improves. It means tha we can change the voice to different voices. Ultimately, it will alow us to translate our courses into different languages quickly and automatically using machine learning. We think this highlights the incredible power of data science and artificial intelligence to improve the world. 


If you find the robot voice annoying, we get it. We know that the technology isn't perfect yet. That's why we've made the written lecture material reflect as closely as possible the video lectures. So you can pick how you want to consume our classes. We hope that this change will allow us to better serve you with the best content at the fastest speed. Thanks for participating in this new phase of course development with us! 


### Slides and Video

![Why Automated Videos](https://www.youtube.com/watch?v=iYSdDfbYPNU)

* [Slides](https://docs.google.com/presentation/d/1FtdynwBR8IAE8x9cMTZrnWKfTPXEhH-KwkAZKQ0zwk8/edit?usp=sharing)