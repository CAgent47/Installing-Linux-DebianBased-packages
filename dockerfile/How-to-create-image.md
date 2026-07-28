# how to create omnipkg docker image and safe run?

---

# 1 - Install Docker

**install docker with docker docs help**

---

# 2 - Create Docker image

**change your directory dockerfile folder**
```bash
# Build Image
sudo docker build -t omnipkg .

# Check Exists & Copy Image Name
sudo docker images
```

---

# 3 - RUN Image
```bash
sudo docker run omnipkg
```

# And
**RELAX**