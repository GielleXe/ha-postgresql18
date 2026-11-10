\getenv recorder_password RECORDER_PASSWORD
CREATE ROLE homeassistant LOGIN PASSWORD :'recorder_password';
ALTER DATABASE homeassistant OWNER TO homeassistant;
