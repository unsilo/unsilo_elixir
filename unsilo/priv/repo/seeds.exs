import Unsilo.Factory

user =
  insert(:user,
    name: "Steven Fuchs",
    email: "steve@tehsnappy.com",
    password_hash: Bcrypt.hash_pwd_salt("testpassword")
  )

insert(:spot,
  name: "namaste",
  domains: ["namaste.industries"],
  user_id: user.id
)

insert(:spot,
  domains: ["lpiu.com", "lpiu2.com"],
  user_id: user.id
)

river_1 =
  insert(:river,
    name: "News",
    user_id: user.id
  )

river_2 =
  insert(:river,
    name: "Science",
    user_id: user.id
  )

insert(:feed,
  url: "http://www.npr.org/rss/rss.php?id=1001",
  river_id: river_1.id,
  user_id: user.id
)

insert(:feed,
  url: "http://feeds.reuters.com/reuters/topNews",
  river_id: river_1.id,
  user_id: user.id
)

insert(:feed,
  url: "http://feeds.bbci.co.uk/news/world/us_and_canada/rss.xml?edition=int",
  river_id: river_1.id,
  user_id: user.id
)

insert(:feed,
  url: "http://feeds.feedburner.com/sciencealert-latestnews",
  river_id: river_2.id,
  user_id: user.id
)

insert(:feed,
  url: "https://www.wired.com/feed/category/science/latest/rss",
  river_id: river_2.id,
  user_id: user.id
)

insert(:feed,
  url: "http://rss.sciam.com/ScientificAmerican-Global",
  river_id: river_2.id,
  user_id: user.id
)

insert(:feed,
  url:
    "https://www.newscientist.com/feed/home?cmpid=RSS|NSNS-Home&utm_medium=RSS&utm_source=NSNS&utm_campaign=Home&utm_content=Home",
  river_id: river_2.id,
  user_id: user.id
)

insert(:location,
  name: "Home",
  type: :local,
  user_id: user.id
)
