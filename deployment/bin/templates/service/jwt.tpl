package service

import (
	"net/http"
	"{{ .ProjectConfig.PackageName }}/config"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/dgrijalva/jwt-go/request"
)

func newJWT(userID string, exp time.Duration) (string, error) {
	token := jwt.New(jwt.SigningMethodHS256)
	claims := make(jwt.MapClaims)

	if exp > 0 {
		claims["exp"] = time.Now().Add(exp * time.Second).Unix()
	}

	claims["aud"] = userID
	claims["iat"] = time.Now().Unix()
	token.Claims = claims

	tokenString, err := token.SignedString([]byte(config.JwtSecretKey))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

func checkJWT(req *http.Request) (bool, error) {
	token, err := request.ParseFromRequest(req, request.AuthorizationHeaderExtractor,
		func(token *jwt.Token) (interface{}, error) {
			return []byte(config.JwtSecretKey), nil
		})
	if err != nil {
		validationErr, ok := err.(*jwt.ValidationError)
		if !ok {
			return false, err
		}

		if validationErr.Errors == jwt.ValidationErrorExpired {
			return false, nil
		}

		return false, err
	}

	if !token.Valid {
		return false, nil
	}

	return token.Valid, nil
}
