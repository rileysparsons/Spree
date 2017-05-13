Spree
=============

## Summary
Spree was started by myself and [Marco Ciccone](https://www.linkedin.com/in/mciccone10) in late 2014 with the vision of enabling students to sell secondhand items like textbooks and furniture to other students, using only their smartphones. 

By March 2015, I had developed a rough prototype native iOS application that allowed users to login with their school email addresses, post items, and communicate with each other. 

In May 2015 we won the grand prize at Santa Clara University's First Annual Business Pitch Competition.

In late May 2015 we debuted the first release of Spree for iOS on the Apple App Store.

## Press
The project recieved a good deal of attention in the Santa Clara University press.
* Santa Clara Magazine (Spring 2016)
https://magazine.scu.edu/scm/article.cfm?b=439&c=23795

* Santa Clara University Center for Innovation and Entrepreneurship (May 2015)
http://cms.scu.edu/business/cie/?c=22242

* The Santa Clara (October 2015)
http://thesantaclara.org/students-develop-local-marketplace-app/

* The Santa Clara (May 2015)
http://thesantaclara.org/marketplace-application-built/

* Her Campus (June 2015)
http://www.hercampus.com/school/scu/spree-app-founders-marco-ciccone-riley-parsons

* Th3Clara.com (June 2015)
http://theclara.co/spree-app-enables-secure-trading-for-scu-students/

* SCU eNews (Summer 2015)
http://issuu.com/hwilliams/docs/scu_enews_summer_2015


## Development Process
In December 2014, I began researching how I might build an app that would allow users to post an item to Spree, and browse for items to purchase, and contact each other when needed. Parse was selected as the backend for the app because I had worked with it previously while developing SceneScope, and it was a fastest way to get the app up and running.

<p align='center'>
<img src="https://github.com/rileysparsons/Spree/blob/master/spree_prototype_demo.gif" width="200">
</p>

The initial version of Spree contained a tab bar with three different views: "All", "Categories", and "More". Posts could be created while browsing in the All tab within a basic view that prompted users to fill in information on what they were selling. The fields included "Title", "Price", "Description", with other fields like "Class" when posting a textbook for sale. Also, users were able to include up to three photos of the item they were selling by selecting the "Add Photo" buttons on the bottom of their screen.

In the next major iteration of the app, a "Messages" tab was added to the tab bar to allow users to contact each other within the app. Previously, the users were forced to contact each other outside of the app interface, leading to a clumsy, less sticky experience. 

<p align='center'>
<img src="https://github.com/rileysparsons/Spree/blob/master/messages_demo.gif" width="200" alt='In-app messaging created a smoother transaction process and increased user retention'>
</p>

Over Summer 2015, the onboarding and new post creation workflow was completely overhauled in order to better the user experience and expand the functionality of the app. Also, we chose to simplify the app's color scheme, opting for the use of simple grey and white tints with blue as a minor accent color. 

<p align='center'>
<img src="https://github.com/rileysparsons/Spree/blob/master/Nov2015Spree.png" width="200" alt='In Fall 2015 we debuted a new version of the app that featured a much cleaner color scheme and overall UI'>
</p>

The new post workflow was revamped, trading the single view for a multiview workflow that dynamically presented views based on what type of item was being posted for sale.

<p align='center'>
<img src="https://github.com/rileysparsons/Spree/blob/master/spree_workflow_image1.png" width="200" alt='Initial view controller of the new post workflow'> <img height="350" hspace="20"/> <img src="https://github.com/rileysparsons/Spree/blob/master/spree_workflow_image2.png" width="200" alt='Text field prompting user to type title of their new post'> 
</p>
