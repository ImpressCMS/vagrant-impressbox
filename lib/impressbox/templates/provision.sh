private_key="%private_key%"
public_key="%public_key%"

if grep -Fxq "$public_key" ~/.ssh/authorized_keys
then
    echo "Your public key is already in authorized keys list... so skipping..."
else
    echo "Inserting public key to authorized_keys list"
	if [ ! -f ~/.ssh/authorized_keys ]; then
		touch ~/.ssh/authorized_keys
	fi
    echo $public_key >> ~/.ssh/authorized_keys
fi

echo "Updating private key..."
touch ~/.ssh/id_rsa
chmod 777 ~/.ssh/id_rsa
echo $private_key > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa

