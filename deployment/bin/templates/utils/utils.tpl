package utils

import (
	"crypto/hmac"
	"crypto/md5"
	"encoding/hex"
	uuid "github.com/satori/go.uuid"
	"strconv"
    "strings"
)

func IsStringEmpty(str string) bool {
	return strings.Trim(str, " ") == ""
}

func Hmac(key string, data string) string {
	hmacHash := hmac.New(md5.New, []byte(key))
	hmacHash.Write([]byte(data))
	return hex.EncodeToString(hmacHash.Sum([]byte("")))
}

func GetUUID() (string, error) {
	u := uuid.NewV4()
	return u.String(), nil
}

func SpiltIDs(idsStr string) ([]uint64, error) {
	ids := make([]uint64, 0)
	for _, idStr := range strings.Split(idsStr, ",") {
		id, err := strconv.ParseUint(idStr, 10, 64)
		if err != nil {
			return nil, err
		}

		ids = append(ids, id)
	}

	return ids, nil
}