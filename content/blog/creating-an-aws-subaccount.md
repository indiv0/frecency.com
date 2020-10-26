+++
title = "Creating an AWS Subaccount"
date = 2020-05-30
+++

For increased security and isolation of concerns, I decided to setup a
subaccount on AWS to manage projects like my personal blog. This way, the
primary account could focus on just managing billing, with no other
responsibilities. Under the secondary account (the subaccount) I also created an
administrative user to log in as, instead of always using the root user for the
subaccount. This is recommended per AWS best practices, because revoking access
to a root account can be tricky.

First, I had to setup consolidated billing on my primary account. To do this:
1. I went to `My Account` in AWS and under `Consolidated billing` I clicked
   `Get started`;
2. on the AWS Organizations page I was brought to I clicked
   `Create organization`;
3. selected `Add account`, then `Create account`;
4. entered my desired AWS account name and email (I left IAM role name blank for
   now), and clicked `Create`.

AWS gave me an error when I tried to click `Create`, saying "You cannot add
accounts to your organization while it is initializing. Try again later".
So in the meantime I went to my email and verified my email address through the
email I received from AWS.

After waiting for about 5 minutes, `Create` finally worked; after another few
minutes, I received an email from AWS informing me my new account was created.

I then went to sign in to AWS, opting to sign in as a `Root user`. I entered the
email I chose when creating the new account, clicked `Next`, then clicked
`Forgot password?`. This was necessary because AWS autogenerates an
unrecoverable password for the root user when the account is created. I asked
for a password reset to be sent, then when the email arrived I followed the
instructions to reset the password.

After completing the password reset, I was able to login with the email of the
new account and the new password. From there, I went to `My Security
Credentials` where I chose `Activate MFA` with a `Virtual MFA device`,
two-factor authentication.

From there, I went to IAM to setup an admin user that I could use for day-to-day
operations (per AWS best practices). I created a new user with the user name
`molly` and enabled `Programmatic access` and `AWS Management Console access`.
On the `Permissions` page, I did the following:
1. Chose `Add user to group`.
2. Chose `Create group`.
3. Set `Group name` to `Administrators`.
4. Selected the check box for the `AdministratorAccess` policy.
5. Chose `Create group`.
6. Chose `Next: Tags`.
Then, I chose `Next: Review` and `Create user`.
I added the `Access key ID`, `Secret access key`, and account ID to my password
manager.

I then logged out from AWS, and logged in as this newly created administrative
user instead. From here, I could use AWS as normal.

I also configured AWS CLI for command line access to AWS:

```sh
$ aws configure
AWS Access Key ID [None]: *************EXAMPLE
AWS Secret Access Key [None]: ******************************EXAMPLEKEY
Default region name [None]: us-east-2
Default output format [None]: json
```
