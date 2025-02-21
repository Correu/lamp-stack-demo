## LAMP Stack Demo application leveraging Docker Containers and PERL as the back end language with a SQL Server DB

### Commands to run teh application
- docker bulid -t 'project-image-name' . (establishes the linux image and builds out the necessary frameworks for the application)
- docker run -d -p 22:22 -p 80:80 -p 3306:3306 --name 'project-container-name' 'project-image-name' (builds the container and connects it to the image, adding the appropriate port mappings)
