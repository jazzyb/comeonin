defmodule Comeonin.BcryptTest do
  use ExUnit.Case, async: false

  alias Comeonin.Bcrypt

  def check_vectors(data) do
    for {password, salt, stored_hash} <- data do
      assert Bcrypt.hashpass(password, salt) == stored_hash
    end
  end

  test "Openwall Bcrypt tests" do
   [{"U*U",
     "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
     "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"},
    {"U*U*",
     "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
     "$2a$05$CCCCCCCCCCCCCCCCCCCCC.VGOzA784oUp/Z0DY336zx7pLYAy0lwK"},
    {"U*U*U",
     "$2a$05$XXXXXXXXXXXXXXXXXXXXXO",
     "$2a$05$XXXXXXXXXXXXXXXXXXXXXOAcXxm9kjPGEMsLznoKqmqw7tc8WCx4a"},
    {"",
     "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
     "$2a$05$CCCCCCCCCCCCCCCCCCCCC.7uG0VCzI2bS7j6ymqJi9CdcdxiRTWNy"},
    {"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
     "$2a$05$abcdefghijklmnopqrstuu",
     "$2a$05$abcdefghijklmnopqrstuu5s2v8.iXieOjg/.AySBTTZIIVFJeBui"}]
    |> check_vectors
  end

  test "OpenBSD Bcrypt tests" do
   [{"\xa3",
     "$2b$05$/OK.fbVrR/bpIqNJ5ianF.",
     "$2b$05$/OK.fbVrR/bpIqNJ5ianF.Sa7shbm4.OzKpvFnX1pQLmQW96oUlCq"},
    {"\xa3",
     "$2a$05$/OK.fbVrR/bpIqNJ5ianF.",
     "$2a$05$/OK.fbVrR/bpIqNJ5ianF.Sa7shbm4.OzKpvFnX1pQLmQW96oUlCq"},
    {"\xff\xff\xa3",
     "$2b$05$/OK.fbVrR/bpIqNJ5ianF.",
     "$2b$05$/OK.fbVrR/bpIqNJ5ianF.CE5elHaaO4EbggVDjb8P19RukzXSM3e"},
    {"000000000000000000000000000000000000000000000000000000000000000000000000",
     "$2a$05$CCCCCCCCCCCCCCCCCCCCC.",
     "$2a$05$CCCCCCCCCCCCCCCCCCCCC.6.O1dLNbjod2uo0DVcW.jHucKbPDdHS"},
    {"000000000000000000000000000000000000000000000000000000000000000000000000",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.6.O1dLNbjod2uo0DVcW.jHucKbPDdHS"}]
    |> check_vectors
  end

  test "Long password Bcrypt tests" do
   [{"012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.XxrQqgBi/5Sxuq9soXzDtjIZ7w5pMfK"},
   {"0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.",
     "$2b$05$CCCCCCCCCCCCCCCCCCCCC.XxrQqgBi/5Sxuq9soXzDtjIZ7w5pMfK"}]
    |> check_vectors
  end

  test "Consistency tests" do
   [{"p@5sw0rd",
     "$2b$12$zQ4CooEXdGqcwi0PHsgc8e",
     "$2b$12$zQ4CooEXdGqcwi0PHsgc8eAf0DLXE/XHoBE8kCSGQ97rXwuClaPam"},
   {"C'est bon, la vie!",
     "$2b$12$cbo7LZ.wxgW4yxAA5Vqlv.",
     "$2b$12$cbo7LZ.wxgW4yxAA5Vqlv.KR6QFPt4qCdc9RYJNXxa/rbUOp.1sw."}]
    |> check_vectors
  end

  test "Bcrypt dummy check" do
    assert Bcrypt.dummy_checkpw == false
  end

  test "hashing and checking passwords" do
    hash = Bcrypt.hashpwsalt("password")
    assert Bcrypt.checkpw("password", hash) == true
    assert Bcrypt.checkpw("passwor", hash) == false
    assert Bcrypt.checkpw("passwords", hash) == false
    assert Bcrypt.checkpw("pasword", hash) == false
  end

  test "gen_salt number of rounds" do
    assert String.starts_with?(Bcrypt.gen_salt(8), "$2b$08$")
    assert String.starts_with?(Bcrypt.gen_salt(20), "$2b$20$")
  end

  test "gen_salt length of salt" do
    assert byte_size(Bcrypt.gen_salt) == 29
    assert byte_size(Bcrypt.gen_salt(8)) == 29
    assert byte_size(Bcrypt.gen_salt(20)) == 29
    assert byte_size(Bcrypt.gen_salt("wrong input but still works")) == 29
  end

  test "wrong input to gen_salt" do
    assert String.starts_with?(Bcrypt.gen_salt(3), "$2b$12$")
    assert String.starts_with?(Bcrypt.gen_salt(32), "$2b$12$")
    assert String.starts_with?(Bcrypt.gen_salt(["wrong type"]), "$2b$12$")
  end

  test "trying to run hashpass without a salt" do
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Bcrypt.hashpass("U*U", "")
    end
  end

  test "wrong input to hashpass" do
    assert_raise ArgumentError, "The salt is the wrong length.", fn ->
      Bcrypt.hashpass("U*U", "$2a$05$CCCCCCCCCCCCCCCCCCC.")
    end
    assert_raise ArgumentError, "Wrong type. The password and salt need to be strings.", fn ->
      Bcrypt.hashpass(["U*U"], "$2a$05$CCCCCCCCCCCCCCCCCCCCC.")
    end
  end

  test "length of state output by NIFs" do
    salt_as_list = Bcrypt.gen_salt |> :erlang.binary_to_list
    for {key, key_len} <- [{'', 1}, {'password', 9}] do
      state = Bcrypt.bf_init(key, key_len, salt_as_list)
      assert byte_size(state) == 4168
      expanded = Bcrypt.bf_expand(state, key, key_len, salt_as_list)
      assert byte_size(expanded) == 4168
    end
  end

  test "bcrypt_log_rounds configuration" do
    prefix = "$2b$08$"
    Application.put_env(:comeonin, :bcrypt_log_rounds, 08)
    assert String.starts_with?(Bcrypt.gen_salt, prefix)
    assert String.starts_with?(Bcrypt.hashpwsalt("password"), prefix)
    Application.delete_env(:comeonin, :bcrypt_log_rounds)
  end
end
