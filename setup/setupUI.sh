# Install the awsmobile cli
npm install -g awsmobile-cli

# Facebook package for creating new create apps
npm install -g create-react-app
create-react-app client
cd client
npm start
echo "Created new react app on localhost:3000"

# Create new project in Mobile Hub
awsmobile init
echo "Created new project in AWS Mobile Hub"

# includes analytics (Pinpoint) and hosting (S3 and CloudFront distrubution)
awsmobile features
# runs npm install, pulls any backend resource updates, executes npm start
awsmobile run

# Install aws react library
npm install aws-amplify-react --save

# Runs local projects build command
# Grabs build in build folder and uploads it to S3, returns S3 and CloudFront urls
awsmobile publish