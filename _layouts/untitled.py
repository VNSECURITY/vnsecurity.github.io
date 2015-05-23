import smtplib
from elasticsearch import Elasticsearch
import socket
import redis


SMTP_SERVER = "localhost"
FROM = "alert@oasis.messagelabs.net"
TO = ["harry_phan@symantec.com"] # must be a list

LOGSTASH_PORT = [1334, 1335, 1336, 1337, 1338]

def port_open(port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    result = sock.connect_ex(('127.0.0.1', port))
    return result == 0

def send_alert(subject, description):

    # Prepare actual message

    message = """\
    From: %s
    To: %s
    Subject: %s

    %s
    """ % (FROM, ", ".join(TO), subject, description)

    # Send the mail

    server = smtplib.SMTP(SERVER)
    server.sendmail(FROM, TO, message)
    server.quit()


# Check elasticsearch status
try:
    es = Elasticsearch()
    health = es.cluster.health()
    if health['status'] == 'red':
        send_alert("ES status is now red", str(health))
except Exception, e:
    send_alert("Couldn't query ES for health status", str(e))

# Check logstash ports
for port in LOGSTASH_PORT:
    if not port_open(port):
        send_alert("Logstash port %d is not open" % port, "")

# Check remaining logs to process
r_server = redis.Redis("localhost")
count = 0
for f in os.listdir('/var/log/radar_receiver'):
    if not f.startswith("@"): continue
    v = r_server.get("radar_"+f)
    if not v:
        count += 1

if count > 100:
    send_alert("%d radar files are waiting to be processed" %d, "")