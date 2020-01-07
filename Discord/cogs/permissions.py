
import discord
from discord.ext import commands

from typing import Optional, Union

from utilities import checks

def setup(bot):
	bot.add_cog(Permissions(bot))

class Permissions(commands.Cog):
	
	def __init__(self, bot):
		self.bot = bot
		
		self.bot.loop.create_task(self.initialize_database())
	
	async def initialize_database(self):
		await self.bot.connect_to_database()
		await self.bot.db.execute("CREATE SCHEMA IF NOT EXISTS permissions")
		await self.bot.db.execute(
			"""
			CREATE TABLE IF NOT EXISTS permissions.everyone (
				guild_id		BIGINT, 
				permission		TEXT, 
				setting			BOOL, 
				PRIMARY KEY		(guild_id, permission)
			)
			"""
		)
		await self.bot.db.execute(
			"""
			CREATE TABLE IF NOT EXISTS permissions.roles (
				guild_id		BIGINT, 
				role_id			BIGINT, 
				permission		TEXT, 
				setting			BOOL, 
				PRIMARY KEY		(guild_id, role_id, permission)
			)
			"""
		)
		await self.bot.db.execute(
			"""
			CREATE TABLE IF NOT EXISTS permissions.users (
				guild_id		BIGINT, 
				user_id			BIGINT, 
				permission		TEXT, 
				setting			BOOL, 
				PRIMARY KEY		(guild_id, user_id, permission)
			)
			"""
		)
	
	@commands.group(invoke_without_command = True, case_insensitive = True)
	@checks.not_forbidden()
	async def setpermission(self, ctx):
		'''Set a permission'''
		await ctx.send_help(ctx.command)
	
	@setpermission.command(name = "everyone")
	@checks.is_permitted()
	@commands.guild_only()
	async def setpermission_everyone(self, ctx, permission: str, setting: Optional[bool]):
		if permission not in self.bot.all_commands:
			return await ctx.embed_reply(f"Error: {permission} is not a command")
		await self.bot.db.execute(
			"""
			INSERT INTO permissions.everyone (guild_id, permission, setting)
			VALUES ($1, $2, $3)
			ON CONFLICT (guild_id, permission) DO
			UPDATE SET setting = $3
			""", 
			ctx.guild.id, self.bot.all_commands[permission].name, setting
		)
		await ctx.embed_reply(f"{permission} set to {setting} for everyone", 
								title = "Permission Updated")
	
	@setpermission.command(name = "role")
	@checks.is_permitted()
	@commands.guild_only()
	async def setpermission_role(self, ctx, role: discord.Role, permission: str, setting: Optional[bool]):
		if permission not in self.bot.all_commands:
			return await ctx.embed_reply(f"Error: {permission} is not a command")
		await self.bot.db.execute(
			"""
			INSERT INTO permissions.roles (guild_id, role_id, permission, setting)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (guild_id, role_id, permission) DO
			UPDATE SET setting = $4
			""", 
			ctx.guild.id, role.id, self.bot.all_commands[permission].name, setting
		)
		await ctx.embed_reply(f"{permission} set to {setting} for the role, {role.mention}", 
								title = "Permission Updated")
	
	@setpermission.command(name = "user", aliases = ["member"])
	@checks.is_permitted()
	@commands.guild_only()
	async def setpermission_user(self, ctx, user: discord.Member, permission: str, setting: Optional[bool]):
		if permission not in self.bot.all_commands:
			return await ctx.embed_reply(f"Error: {permission} is not a command")
		await self.bot.db.execute(
			"""
			INSERT INTO permissions.users (guild_id, user_id, permission, setting)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (guild_id, user_id, permission) DO
			UPDATE SET setting = $4
			""", 
			ctx.guild.id, user.id, self.bot.all_commands[permission].name, setting
		)
		await ctx.embed_reply(f"{permission} set to {setting} for {user.mention}", 
								title = "Permission Updated")
	
	@commands.group(invoke_without_command = True, case_insensitive = True)
	@checks.is_permitted()
	@commands.guild_only()
	async def getpermission(self, ctx, permission, users: Optional[Union[discord.Member, discord.Role]]):
		'''
		Get a permission for a user, role, or everyone
		Defaults to everyone if no user or role is specified
		'''
		if permission not in self.bot.all_commands:
			return await ctx.embed_reply(f"Error: {permission} is not a command")
		if not users:
			setting = await ctx.get_permission(self.bot.all_commands[permission].name, type = "everyone")
			return await ctx.embed_reply(f"{permission} is set to {setting} for everyone")
		if isinstance(users, discord.Member):
			setting = await ctx.get_permission(self.bot.all_commands[permission].name, id = users.id)
			return await ctx.embed_reply(f"{permission} is set to {setting} for {users.mention}")
		if isinstance(users, discord.Role):
			setting = await ctx.get_permission(self.bot.all_commands[permission].name, 
												type = "role", id = users.id)
			return await ctx.embed_reply(f"{permission} is set to {setting} for the role, {users.mention}")
	
	@commands.group(invoke_without_command = True, case_insensitive = True)
	@checks.not_forbidden()
	async def getpermissions(self, ctx):
		await ctx.send_help(ctx.command)
	
	@getpermissions.command(name = "everyone")
	@checks.is_permitted()
	@commands.guild_only()
	async def getpermissions_everyone(self, ctx):
		records = await ctx.bot.db.fetch(
			"""
			SELECT permission, setting FROM permissions.everyone
			WHERE guild_id = $1
			""", 
			ctx.guild.id
		)
		output = "__Permissions for everyone__\n"
		for record in records:
			output += "{}: {}\n".format(record["permission"], str(record["setting"]))
		await ctx.send(output)
	
	@getpermissions.command(name = "role")
	@checks.is_permitted()
	@commands.guild_only()
	async def getpermissions_role(self, ctx, role : discord.Role):
		records = await ctx.bot.db.fetch(
			"""
			SELECT permission, setting FROM permissions.roles
			WHERE guild_id = $1 AND role_id = $2
			""", 
			ctx.guild.id, role.id
		)
		output = "__Permissions for {}__\n".format(role.name)
		for record in records:
			output += "{}: {}\n".format(record["permission"], str(record["setting"]))
		await ctx.send(output)
	
	@getpermissions.command(name = "user")
	@checks.is_permitted()
	@commands.guild_only()
	async def getpermissions_user(self, ctx, user : discord.Member):
		records = await ctx.bot.db.fetch(
			"""
			SELECT permission, setting FROM permissions.users
			WHERE guild_id = $1 AND user_id = $2
			""", 
			ctx.guild.id, user.id
		)
		output = "__Permissions for {}__\n".format(user.name)
		for record in records:
			output += "{}: {}\n".format(record["permission"], str(record["setting"]))
		await ctx.send(output)
	
	@getpermissions.command(name = "command")
	@checks.is_permitted()
	@commands.guild_only()
	async def getpermissions_command(self, ctx, command : str):
		if command not in self.bot.all_commands: return (await ctx.embed_reply("Error: {} is not a command".format(command)))
		output = "__Permissions for {}__\n".format(command)
		setting = await ctx.bot.db.fetchval(
			"""
			SELECT setting FROM permissions.everyone
			WHERE guild_id = $1 AND permission = $2
			""", 
			ctx.guild.id, command
		)
		output += "**Everyone**: {}\n".format(setting)
		output += "**Roles**\n"
		records = await ctx.bot.db.fetch(
			"""
			SELECT role_id, setting FROM permissions.roles
			WHERE guild_id = $1 AND permission = $2
			""", 
			ctx.guild.id, command
		)
		for record in records:
			output += "{}: {}\n".format(ctx.guild.get_role(record["role_id"]), str(record["setting"]))
			# TODO: Handle role no longer existing
		output += "**Users**\n"
		records = await ctx.bot.db.fetch(
			"""
			SELECT user_id, setting FROM permissions.users
			WHERE guild_id = $1 AND permission = $2
			""", 
			ctx.guild.id, command
		)
		for record in records:
			output += "{}: {}\n".format(ctx.bot.get_user(record["user_id"]), str(record["setting"]))
			# TODO: Handle user no longer visible
		await ctx.send(output)

