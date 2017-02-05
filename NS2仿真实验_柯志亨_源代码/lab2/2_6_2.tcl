set person_info(name) "Fred Smith"
set person_info(age) "25"
set person_info(occupation) "Plumber"

foreach thing {name age occupation} {
puts "$thing == $person_info($thing)"
}
