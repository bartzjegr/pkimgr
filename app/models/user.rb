class User < ApplicationRecord
  has_secure_password
  has_and_belongs_to_many :authorities
  has_many :requests, class_name: "CertSigningRequest", as: :subject
  has_many :certificates, class_name: "Certificate", as: :subject

  def name
    "#{self.firstname} #{self.lastname}"
  end

  def x509(additionals = [])
    OpenSSL::X509::Name.new [
      ["C", self.country],
      ["ST", self.state],
      ["L", self.city],
      ["O", "#{self.name} Org."], # TODO user's organization
      ["OU", self.name],
      ["emailAddress", self.email],
      # CN needs to be set by caller
      *additionals,
    ]
  end

  def get_encrypt_key(password)
    self.encrypt_key_pem && OpenSSL::PKey.read(self.encrypt_key_pem, password)
  end

  def set_encrypt_key(e, password)
    self.encrypt_key_pem = e.to_pem(Rails.application.config.cipher, password)
  end

  def get_sign_key(password)
    self.sign_key_pem && OpenSSL::PKey.read(self.sign_key_pem, password)
  end

  def set_sign_key(e, password)
    self.sign_key_pem = e.to_pem(Rails.application.config.cipher, password)
  end
end
