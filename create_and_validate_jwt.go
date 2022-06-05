package main

import (
	"fmt"
	"time"

	"github.com/golang-jwt/jwt"
	"github.com/google/uuid"
	"github.com/leekchan/timeutil"
)

func main() {

	base := time.Now()
	td := timeutil.Timedelta{Minutes: 15}
	result := base.Add(td.Duration())

	mySigningKey := []byte("Very long secret key string")

	type SystemClaim struct {
		Creator    string `json:"creator"`
		ForService string `json:"forService"`
		jwt.StandardClaims
	}

	// Create the Claims
	claims := SystemClaim{
		"Signer",
		"Calendar",
		jwt.StandardClaims{
			ExpiresAt: result.Unix(),
			Id:        uuid.New().String(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, _ := token.SignedString(mySigningKey)
	fmt.Println(tokenString)

	// ===========================
	// VERIFICATION
	// ===========================
	token, err := jwt.ParseWithClaims(tokenString, &SystemClaim{}, func(token *jwt.Token) (interface{}, error) {
		return []byte("Very long secret key string"), nil
	})

	if token.Valid {
		fmt.Println("Token is correct")

		if claims, ok := token.Claims.(*SystemClaim); ok && token.Valid {
			fmt.Println("Creator:", claims.Creator)
			fmt.Println("ForService:", claims.ForService)
			fmt.Println("ExpiresAt:", claims.StandardClaims.ExpiresAt)
			fmt.Println("Id:", claims.StandardClaims.Id)
		} else {
			fmt.Println(err)
		}

	} else if ve, ok := err.(*jwt.ValidationError); ok {
		// Checking errors
		if ve.Errors&jwt.ValidationErrorMalformed != 0 {
			fmt.Println("Not a token")
		} else if ve.Errors&(jwt.ValidationErrorExpired|jwt.ValidationErrorNotValidYet) != 0 {
			fmt.Println("Expired or not active")
		} else {
			fmt.Println("Couldn't handle this token:", err)
		}
	} else {
		fmt.Println("Couldn't handle this token:", err)
	}

}
