import Unsilo.Factory

user = insert(:user,  name: "Steven Fuchs",
                      email: "steve@tehsnappy.com",
                      password_hash: Bcrypt.hash_pwd_salt("testpassword"))

insert(:spot, name: "namaste",
              domains: ["namaste.industries"],
              user_id: user.id)
insert(:spot, domains: ["lpiu.com", "lpiu2.com"],
              user_id: user.id)
