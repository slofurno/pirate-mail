require 'yaml'
require 'aws-sdk'
require 'openssl'
require 'Process'

creds = YAML.load(File.read('secrets/aws.yml'))

client = Aws::SES::Client.new(
    #credentials: Aws::Credentials.new(creds['email_login'], creds['email_token']),
    access_key_id: creds['access_key_id'],
    secret_access_key: creds['secret_access_key'],
    region: creds['region'],
   # server: "email-smtp.us-east-1.amazonaws.com",
)

resp = client.send_email({
    source: "noreply@gdf3.com",
    destination: {
        to_addresses: ["slofurno@gmail.com"],
    },
    message: {
        subject: {
            data: "YOYOYOY",
        },
        body: {
            text: {
                data: "HEY< THIS IS FROM RUBY",
            },
        },
    },
#    source_arn: "arn:aws:ses:us-east-1:282504693794:identity/noreply@gdf3.com",
})

def make_email_hash(secret, email)
    return OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, email)
end

def check_email_hash(secret, email, hash)
    hashed = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, email)
    return hashed == hash
end

secret = creds['sha_key']
hash = make_email_hash(secret, "slofurno@gmail.com")
puts check_email_hash(secret, "slofurno@gmail.com", hash)


