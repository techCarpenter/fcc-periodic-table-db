PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

re='^[0-9]+$'
if [[ $1 =~ $re ]] ; then
  atomic_number_count=$($PSQL "SELECT COUNT(*) FROM elements WHERE atomic_number = $1")
else
  atomic_number=-1
fi

symbol_count=$($PSQL "SELECT COUNT(*) FROM elements WHERE symbol = '$1'")
name_count=$($PSQL "SELECT COUNT(*) FROM elements WHERE name = '$1'")
query=""

if [[ $atomic_number_count -gt 0 ]]; then
  query="SELECT e.name, e.symbol, p.atomic_number, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type FROM elements e JOIN properties p on e.atomic_number = p.atomic_number JOIN types t on p.type_id = t.type_id WHERE e.atomic_number = $1;"
elif [[ $symbol_count -gt 0 ]]; then
  query="SELECT e.name, e.symbol, p.atomic_number, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type FROM elements e JOIN properties p on e.atomic_number = p.atomic_number JOIN types t on p.type_id = t.type_id WHERE e.symbol = '$1';"
elif [[ $name_count -gt 0 ]]; then
  query="SELECT e.name, e.symbol, p.atomic_number, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type FROM elements e JOIN properties p on e.atomic_number = p.atomic_number JOIN types t on p.type_id = t.type_id WHERE e.name = '$1';"
else
  echo "I could not find that element in the database."
  exit
fi

while IFS='|' read -r name symbol atomic_number atomic_mass melting_point boiling_point type; do
  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
done <<< $($PSQL "$query")
